module StackMaster
  module Commands
    class Validate
      include Command
      include Commander::UI

      def perform
        failed unless Validator.valid?(@stack_definition, @config, @options)
      end
    end
  end
end
