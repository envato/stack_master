module StackMaster
  module Commands
    class Diff
      include Command
      include Commander::UI

      def perform
        StackMaster::StackDiffer.new(proposed_stack, stack, force_template_json: @options.force_template_json).output_diff
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def stack
        @stack ||= Stack.find(@stack_definition.region, @stack_definition.stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(stack_definition, @config)
      end
    end
  end
end
