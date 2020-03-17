require 'tempfile'

module StackMaster
  module Commands
    class Lint
      include Command
      include Commander::UI

      def perform
        unless cfn_lint_available
          failed! 'Failed to run cfn-lint. You may need to install it using'\
                  '`pip install cfn-lint`, or add it to $PATH.'\
                  "\n"\
                  '(See https://github.com/aws-cloudformation/cfn-python-lint'\
                  ' for package information)'
        end

        Tempfile.open(['stack', ".#{proposed_stack.template_format}"]) do |f|
          f.write(proposed_stack.template_body)
          f.flush
          system('cfn-lint', f.path)
          puts "cfn-lint run complete"
        end
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(stack_definition, @config)
      end

      def cfn_lint_available
        !system('cfn-lint', '--version').nil?
      end
    end
  end
end
