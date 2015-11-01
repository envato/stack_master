module StackMaster
  module Commands
    class ListStacks
      include Command
      include Commander::UI

      def initialize(config)
        @config = config
      end

      def perform
        tp @config.stacks, :region, :stack_name
      end
    end
  end
end
