module StackMaster
  module Commands
    class Validate
      include Command
      include Commander::UI

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
      end

      def perform
        failed unless Validator.valid?(@stack_definition)
      end
    end
  end
end
