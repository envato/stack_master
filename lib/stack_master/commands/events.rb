module StackMaster
  module Commands
    class Events
      include Command
      include Commander::UI

      def perform
        events = StackEvents::Fetcher.fetch(@stack_definition.stack_name, @stack_definition.region)
        filter_events(events).each do |event|
          StackEvents::Presenter.print_event(StackMaster.stdout, event)
        end
        return unless @options.tail

        StackEvents::Streamer.stream(@stack_definition.stack_name, @stack_definition.region, io: StackMaster.stdout)
      end

      private

      def filter_events(events)
        if @options.all
          events
        else
          n = @options.number || 25
          from = events.count - n
          from = 0 if from < 0
          events[from..-1]
        end
      end
    end
  end
end
