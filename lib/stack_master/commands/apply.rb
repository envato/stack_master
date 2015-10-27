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
        diff_stack
        unless ask?("Continue and apply the stack (y/n)? ")
          puts "Stack update aborted"
          return
        end
        create_or_update_stack
        tail_stack_events
      end

      private

      def cf
        @cf ||= Aws::CloudFormation::Client.new(region: @region)
      end

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def stack
        @stack ||= Stack.find(@region, @stack_name)
      end

      def stack_exists?
        !stack.nil?
      end

      def diff_stack
        StackMaster::StackDiffer.perform(stack_definition)
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
        cf.create_stack(stack_options.merge(tags: stack_definition.aws_tags))
      end

      def stack_options
        {
          stack_name: @stack_name,
          template_body: stack_definition.template_body,
          parameters: stack_definition.aws_parameters,
          capabilities: ['CAPABILITY_IAM']
        }
      end

      def tail_stack_events
        StackEvents::Streamer.stream(@stack_name, @region, io: STDOUT)
      end

      def ask?(question)
        print question
        answer = STDIN.getch.chomp
        puts
        answer == 'y'
      end
    end
  end
end
