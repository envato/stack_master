module StackMaster
  module Commands
    class Diff
      include Command
      include Commander::UI

      def initialize(config, region, stack_name)
        @config = config
        @region = region
        @stack_name = stack_name
      end

      def perform
        StackDiffer.perform(stack_definition)
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end
    end
  end
end
