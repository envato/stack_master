module StackMaster
  module Commands
    class ListStacks
      include Command
      include Commander::UI

      def initialize(config)
        @config = config
      end

      def perform
        puts "Region\tStack Name"
        @config.stack_definitions.stacks.each do |stack_definition|
          puts "#{stack_definition.region}\t#{stack_definition.stack_name}"
        end
      end
    end
  end
end
