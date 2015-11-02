module StackMaster
  module Commands
    class Diff
      include Command
      include Commander::UI

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
      end

      def perform
        StackMaster::StackDiffer.new(proposed_stack, stack).output_diff
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def stack
        @stack ||= Stack.find(@region, @stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(stack_definition, @config)
      end
    end
  end
end
