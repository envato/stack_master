module StackMaster
  module Commands
    class Nag
      include Command
      include Commander::UI

      def perform
        Tempfile.open(['stack', "___#{stack_definition.stack_name}.#{proposed_stack.template_format}"]) do |f|
          f.write(proposed_stack.template_body)
          f.flush
          system('cfn_nag', f.path)
          STDERR.puts "cfn_nag run complete"
        end
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
