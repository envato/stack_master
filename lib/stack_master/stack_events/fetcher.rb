module StackMaster
  module StackEvents
    class Fetcher
      def self.fetch(*args)
        new(*args).fetch
      end

      def initialize(stack_name, region, from: nil)
        @stack_name = stack_name
        @region = region
        @from = from
      end

      def fetch
        events = fetch_events
        if @from
          filter_old_events(events)
        else
          events
        end
      end

      private

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end

      def filter_old_events(events)
        events.select { |event| event.timestamp > @from }
      end

      def fetch_events
        PagedResponseAccumulator.call(cf, :describe_stack_events, { stack_name: @stack_name }, :stack_events).stack_events
      end
    end
  end
end
