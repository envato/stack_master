module StackMaster
  module Commands
    class Apply
      include Command
      include Commander::UI

      def initialize(config, region, stack_name)
        @config = config
        @region = region.gsub('_', '-')
        @stack_name = stack_name.gsub('_', '-')
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

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def stack
        @stack ||= Stack.find(@region, @stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(stack_definition, @config)
      end

      def stack_exists?
        !stack.nil?
      end

      def diff_stacks
        StackDiffer.perform(proposed_stack, stack)
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
          stack_name: @stack_name,
          template_body: proposed_stack.template_body,
          parameters: proposed_stack.aws_parameters,
          capabilities: ['CAPABILITY_IAM']
        }
      end

      def tail_stack_events
        StackEvents::Streamer.stream(@stack_name, @region, io: StackMaster.stdout)
      end

      def ask?(question)
        StackMaster.stdout.print question
        answer = if ENV['STUB_AWS']
                   ENV['ANSWER']
                 else
                   STDIN.getch.chomp
                 end
        StackMaster.stdout.puts
        answer == 'y'
      end
    end
  end
end
