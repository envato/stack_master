module StackMaster
  module Commands
    class Compile
      include Command
      include Commander::UI

      def perform
        puts(proposed_stack.template_body)
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(stack_definition, @config)
      end
    end
  end
end
