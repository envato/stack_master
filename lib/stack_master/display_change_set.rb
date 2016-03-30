module StackMaster
  class DisplayChangeSet
    include Command

    def initialize(change_set_id)
      @change_set_id = change_set_id
    end

    def perform
      response = nil
      StackMaster.stdout.puts "Proposed change set:"
      begin
        response = PagedResponseAccumulator.call(cf, :describe_change_set, { change_set_name: @change_set_id }, :changes)
      end while !end_state?(response.status)
      if response.status == 'FAILED'
        StackMaster.stdout.puts response.status_reason
        failed
      else
        response.changes.each do |change|
          display_resource_change(change.resource_change)
        end
      end
    end

    private

    def cf
      @cf ||= StackMaster.cloud_formation_driver
    end

    def display_resource_change(resource_change)
      action_name = if resource_change.replacement == 'True'
                      'Replace'
                    else
                      resource_change.action
                    end
      message = "#{action_name} #{resource_change.resource_type} #{resource_change.logical_resource_id}"
      color = action_color(action_name)
      StackMaster.stdout.puts message.colorize(color)
      resource_change.details.each do |detail|
        detail_messages = [ detail.target.name || detail.target.attribute ]
        if action_name == 'Replace'
          detail_messages << "#{detail.target.requires_recreation} requires recreation"
        end
        detail_messages << "Change source: #{detail.change_source}"
        if detail.evaluation != 'Static'
          detail_messages << "#{detail.evaluation} evaluation"
        end
        if detail.causing_entity
          detail_messages << "Causing entity: #{detail.causing_entity}"
        end
        StackMaster.stdout.puts "- #{detail_messages.join('. ')}. ".colorize(color)
      end
    end

    def action_color(action_name)
      case action_name
      when 'Add'
        :green
      when 'Modify'
        :yellow
      when 'Remove', 'Replace'
        :red
      end
    end

    END_STATES = [
      'CREATE_COMPLETE',
      'DELETE_COMPLETE',
      'FAILED'
    ]

    def end_state?(status)
      END_STATES.include?(status)
    end
  end
end
