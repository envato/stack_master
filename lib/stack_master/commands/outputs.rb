require 'table_print'

module StackMaster
  module Commands
    class Outputs
      include Command
      include Commander::UI
      include StackMaster::Commands::TerminalHelper

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
      end

      def perform
        if stack
          tp.set :max_width, self.window_size
          tp stack.outputs, :output_key, :output_value, :description
        else
          failed("Stack doesn't exist")
        end
      end

      private

      def stack
        @stack ||= Stack.find(@stack_definition.region, @stack_definition.stack_name)
      end
    end
  end
end
