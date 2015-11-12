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
        Validator.perform(@stack_definition)
      end
    end
  end
end
