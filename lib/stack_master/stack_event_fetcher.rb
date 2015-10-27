module StackMaster
  class StackEventFetcher
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
      @cf ||= Aws::CloudFormation::Client.new(region: @region)
    end

    def filter_old_events(events)
      events.select { |event| event.timestamp > @from }
    end

    def fetch_events
      events = []
      next_token = nil
      begin
        response = cf.describe_stack_events(stack_name: @stack_name, next_token: next_token)
        next_token = response.next_token
        events += response.stack_events
      end while !next_token.nil?
      events.reverse
    end
  end
end
