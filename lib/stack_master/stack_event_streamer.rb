module StackMaster
  class StackEventStreamer
    def self.stream(*args, &block)
      new(*args, &block).stream
    end

    def initialize(stack_name, region, from: Time.now, break_on_finish_state: true, sleep_between_fetches: 1, &block)
      @stack_name = stack_name
      @region = region
      @block = block
      @seen_events = Set.new
      @from = from
      @break_on_finish_state = break_on_finish_state
      @sleep_between_fetches = sleep_between_fetches
    end

    def stream
      catch(:halt) do
        loop do
          events = StackEventFetcher.fetch(@stack_name, @region, from: @from)
          unseen_events(events).each do |event|
            @block.call(event)
            if @break_on_finish_state && StackStates.finish_state?(event.resource_status)
              throw :halt
            end
          end
          sleep @sleep_between_fetches
        end
      end
    end

    private

    def unseen_events(events)
      [].tap do |unseen_events|
        events.each do |event|
          next if @seen_events.include?(event.event_id)
          @seen_events << event.event_id
          unseen_events << event
        end
      end
    end
  end
end
