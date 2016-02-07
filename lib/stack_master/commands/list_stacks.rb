module StackMaster
  module Commands
    class ListStacks
      include Command
      include Commander::UI
      include StackMaster::Commands::TerminalHelper

      def initialize(config, options = {})
        @config = config
        @options = options
      end

      def perform
        if @options.machine_readable
          @config.stacks.each do |stack|
            StackMaster.stdout.puts "#{stack.region} #{stack.stack_name}"
          end
        else
          tp.set :max_width, self.window_size
          tp @config.stacks, :region, :stack_name
        end
      end
    end
  end
end
