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
      end

      def perform
        diff_stacks
        unless ask?("Continue and apply the stack (y/n)? ")
          StackMaster.stdout.puts "Stack update aborted"
          return
        end
        create_or_update_stack
        tail_stack_events
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

      def create_or_update_stack
        if stack_exists?
          update_stack
        else
          create_stack
        end
      end

      def update_stack
        cf.update_stack(stack_options)
      end

      def create_stack
        cf.create_stack(stack_options.merge(tags: proposed_stack.aws_tags))
      end

      def stack_options
        {
          stack_name: @stack_definition.stack_name,
          template_body: proposed_stack.template_body,
          parameters: proposed_stack.aws_parameters,
          capabilities: ['CAPABILITY_IAM'],
          notification_arns: proposed_stack.notification_arns,
          stack_policy_body: proposed_stack.stack_policy_body
        }
      end

      def tail_stack_events
        StackEvents::Streamer.stream(@stack_definition.stack_name, @stack_definition.region, io: StackMaster.stdout, from: @from_time)
      end
    end
  end
end
