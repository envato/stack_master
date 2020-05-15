module StackMaster
  class ChangeSet
    END_STATES = [
      'CREATE_COMPLETE',
      'DELETE_COMPLETE',
      'FAILED'
    ]

    def self.generate_change_set_name(stack_name)
      stack_name + '-StackMaster' + Time.now.strftime('%Y-%m-%d-%H%M-%s')
    end

    def self.create(create_options)
      cf = StackMaster.cloud_formation_driver
      change_set_name = generate_change_set_name(create_options.fetch(:stack_name))
      change_set_id = cf.create_change_set(create_options.merge(change_set_name: change_set_name)).id
      find(change_set_id)
    end

    def self.find(id)
      begin
        response = PagedResponseAccumulator.call(cf, :describe_change_set, { change_set_name: id }, :changes)
      end while !END_STATES.include?(response.status)
      new(response)
    end

    def self.delete(id)
      cf.delete_change_set(change_set_name: id)
    end

    def self.execute(id, stack_name)
      cf.execute_change_set(change_set_name: id,
                            stack_name: stack_name)
    end

    def self.cf
      StackMaster.cloud_formation_driver
    end

    def initialize(describe_change_set_response)
      @response = describe_change_set_response
    end

    def display(io)
      io.puts <<-EOL

========================================
Proposed change set:
EOL
      @response.changes.each do |change|
        display_resource_change(io, change.resource_change)
      end
io.puts "========================================"
    end

    def failed?
      @response.status == 'FAILED'
    end

    def status_reason
      @response.status_reason
    end

    def id
      @response.change_set_id
    end

    private

    def display_resource_change(io, resource_change)
      action_name = if resource_change.replacement == 'True'
                      'Replace'
                    else
                      resource_change.action
                    end
      message = "#{action_name} #{resource_change.resource_type} #{resource_change.logical_resource_id}"
      color = action_color(action_name)
      io.puts Rainbow(message).color(color)
      resource_change.details.each do |detail|
        display_resource_change_detail(io, action_name, color, detail)
      end
    end

    def display_resource_change_detail(io, action_name, color, detail)
      target_name = [detail.target.attribute, detail.target.name].compact.join('.')
      detail_messages = [target_name]
      if action_name == 'Replace'
        detail_messages << "#{detail.target.requires_recreation} requires recreation"
      end
      triggered_by = [detail.change_source, detail.causing_entity].compact.join('.')
      if detail.evaluation != 'Static'
        triggered_by << "(#{detail.evaluation})"
      end
      detail_messages << "Triggered by: #{triggered_by}"
      io.puts Rainbow("- #{detail_messages.join('. ')}. ").color(color)
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
  end
end
