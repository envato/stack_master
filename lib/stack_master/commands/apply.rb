module StackMaster
  module Commands
    class Apply
      include Command
      include Commander::UI

      def initialize(config, region, stack_name)
        @config = config
        @region = region
        @stack_name = stack_name
      end

      def perform
        diff_stack
        print "Continue and apply the stack (y/n)? "
        if STDIN.getch.chomp == 'y'
          if stack_exists?
            update_stack
          else
            create_stack
          end
        else
          puts "Stack update aborted"
        end
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
        StackMaster::CloudFormation::DiffStack.perform(cf, stack_definition)
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
    end
  end
end
