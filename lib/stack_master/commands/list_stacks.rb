require 'table_print'

module StackMaster
  module Commands
    class ListStacks
      include Command
      include Commander::UI
      include StackMaster::Commands::TerminalHelper

      def initialize(config)
        @config = config
      end

      def perform
        tp.set :max_width, self.window_size
        tp @config.stacks, :environment, :stack_name, :region
      end
    end
  end
end
