module StackMaster
  module Commands
    class Events
      include Command
      include Commander::UI

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
        @options = options
      end

      def perform
        events = StackEvents::Fetcher.fetch(@stack_definition.raw_stack_name, @stack_definition.region)
        filter_events(events).each do |event|
          StackEvents::Presenter.print_event(StackMaster.stdout, event)
        end
        if @options.tail
          StackEvents::Streamer.stream(@stack_definition.raw_stack_name, @stack_definition.region, io: StackMaster.stdout)
        end
      end

      private

      def filter_events(events)
        if @options.all
          events
        else
          n = @options.number || 25
          from = events.count - n
          if from < 0
            from = 0
          end
          events[from..-1]
        end
      end
    end
  end
end
