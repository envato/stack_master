require 'table_print'

module StackMaster
  module Commands
    class ListStacks
      include Command
      include Commander::UI
      include StackMaster::Commands::TerminalHelper

      def perform
        tp.set :max_width, window_size
        tp @config.stacks, :region, :stack_name
      end
    end
  end
end
