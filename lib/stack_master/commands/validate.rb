module StackMaster
  module Commands
    class Validate
      include Command
      include Commander::UI

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
        @options = options
      end

      def perform
        failed unless Validator.valid?(@stack_definition, @config)
      end
    end
  end
end
