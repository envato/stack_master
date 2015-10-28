module StackMaster
  module Commands
    class Validate
      include Command
      include Commander::UI

      def initialize(config, region, stack_name)
        @config = config
        @region = region
        @stack_name = stack_name
      end

      def perform
        if stack_definition
          Validator.perform(stack_definition)
        else
          $stderr.puts("Unable to find stack '#{@stack_name}' in region #{@region}")
        end
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end
    end
  end
end
