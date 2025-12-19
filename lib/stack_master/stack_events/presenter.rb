module StackMaster
  module StackEvents
    class Presenter
      def self.print_event(io, event)
        new(io).print_event(event)
      end

      def initialize(io)
        @io = io
      end

      def print_event(event)
        @io.puts(
          Rainbow(
            "#{event.timestamp.localtime} #{event.logical_resource_id} #{event.resource_type} " \
            "#{event.resource_status} #{event.resource_status_reason}"
          ).color(event_colour(event))
        )
      end

      def event_colour(event)
        if StackStates.failure_state?(event.resource_status)
          :red
        elsif StackStates.success_state?(event.resource_status)
          :green
        else
          :yellow
        end
      end
    end
  end
end
