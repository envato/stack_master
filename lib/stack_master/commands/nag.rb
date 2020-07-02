module StackMaster
  module Commands
    class Nag
      include Command
      include Commander::UI

      def perform
        unless cfn_nag_available
          failed! 'Failed to run cfn_nag. You may need to install it using'\
                  '`gem install cfn_nag`, or add it to $PATH.'\
                  "\n"\
                  '(See https://github.com/stelligent/cfn_nag'\
                  ' for package information)'
        end

        if proposed_stack.template_format == :yaml
          failed! 'cfn_nag doesn\'t support yaml formatted templates.'
        end

        Tempfile.open(['stack', "___#{stack_definition.stack_name}.#{proposed_stack.template_format}"]) do |f|
          f.write(proposed_stack.template_body)
          f.flush
          system('cfn_nag', f.path)
          puts "cfn_nag run complete"
        end
      end

      private

      def stack_definition
        @stack_definition ||= @config.find_stack(@region, @stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(stack_definition, @config)
      end

      def cfn_nag_available
        system('type -a cfn_nag >/dev/null 2>&1')
        $?.exitstatus == 0
      end
    end
  end
end
