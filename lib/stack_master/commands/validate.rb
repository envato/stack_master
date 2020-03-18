module StackMaster
  module Commands
    class Validate
      include Command
      include Commander::UI

      def perform
        failed unless Validator.valid?(@stack_definition, @config)
      end
    end
  end
end
