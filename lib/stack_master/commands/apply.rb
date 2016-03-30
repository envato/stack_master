module StackMaster
  module Commands
    class Apply
      include Command
      include Commander::UI
      include StackMaster::Prompter

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
        @from_time = Time.now
        @updating = false
      end

      def perform
        diff_stacks
        if @proposed_stack.missing_parameters?
          StackMaster.stderr.puts "Empty/blank parameters detected, ensure values exist for those parameters. Parameters will be read from the following locations:"
          @stack_definition.parameter_files.each do |parameter_file|
            StackMaster.stderr.puts " - #{parameter_file}"
          end
          halt!
        end
        begin
          halt! if stack_too_big
          if stack_exists?
            update_stack
          else
            unless ask?("Create stack (y/n)? ")
              failed!("Stack creation aborted")
            end
            create_stack
          end
          tail_stack_events
        rescue StackMaster::CtrlC
          cancel
        end
      rescue Aws::CloudFormation::Errors::ServiceError => e
        StackMaster.stdout.puts "#{e.class} #{e.message}"
      end

      private

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end

      def stack
        @stack ||= Stack.find(@stack_definition.region, @stack_definition.stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(@stack_definition, @config)
      end

      def stack_exists?
        !stack.nil?
      end

      def diff_stacks
        StackDiffer.new(proposed_stack, stack).output_diff
      end

      def cancel
        if @updating
          if ask?("Cancel stack update?")
            StackMaster.stdout.puts "Attempting to cancel stack update"
            cf.cancel_update_stack({stack_name: @stack_definition.stack_name})
            tail_stack_events
          end
        end
      end

      def stack_too_big
        if proposed_stack.too_big?
          StackMaster.stdout.puts 'The (space compressed) stack is larger than the limit set by AWS. See http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html'
          true
        else
          false
        end
      end

      def update_stack
        @updating = true
        create_change_set
        result = DisplayChangeSet.perform(@change_set_id)
        failed! unless result.success?
        unless ask?("Apply change set (y/n)? ")
          delete_change_set
          halt! "Stack update aborted"
        end
        execute_change_set
      end

      def create_stack
        cf.create_stack(stack_options.merge(tags: proposed_stack.aws_tags))
      end

      def stack_options
        {
          stack_name: @stack_definition.stack_name,
          template_body: proposed_stack.maybe_compressed_template_body,
          parameters: proposed_stack.aws_parameters,
          capabilities: ['CAPABILITY_IAM'],
          notification_arns: proposed_stack.notification_arns,
          stack_policy_body: proposed_stack.stack_policy_body
        }
      end

      def tail_stack_events
        StackEvents::Streamer.stream(@stack_definition.stack_name, @stack_definition.region, io: StackMaster.stdout, from: @from_time)
      end

      def create_change_set
        @change_set_name = 'StackMaster' + Time.now.strftime('%Y-%m-%e-%H%M-%s')
        @change_set_id = cf.create_change_set(stack_options.merge(change_set_name: @change_set_name)).id
      end

      def delete_change_set
        cf.delete_change_set(change_set_name: @change_set_id)
      end

      def execute_change_set
        cf.execute_change_set(change_set_name: @change_set_id,
                              stack_name: @stack_definition.stack_name)
      end
    end
  end
end
