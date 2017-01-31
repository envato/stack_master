module StackMaster
  module AwsDriver
    class CloudFormation
      extend Forwardable

      def region
        @region ||= ENV['AWS_REGION'] || Aws.config[:region] || Aws.shared_config.region
      end

      def set_region(value)
        if region != value
          @region = value
          @cf = nil
        end
      end

      def_delegators :cf, :create_change_set,
                          :describe_change_set,
                          :execute_change_set,
                          :delete_change_set,
                          :delete_stack,
                          :cancel_update_stack,
                          :describe_stack_resources,
                          :get_template,
                          :get_stack_policy,
                          :describe_stack_events,
                          :update_stack,
                          :create_stack,
                          :validate_template

      def describe_stacks(options)
        retry_with_backoff do
          cf.describe_stacks(options)
        end
      end

      private

      def cf
        @cf ||= Aws::CloudFormation::Client.new(region: region)
      end

      def retry_with_backoff
        delay       = 1
        max_delay   = 30
        begin
          yield
        rescue Aws::CloudFormation::Errors::Throttling => e
          if e.message =~ /Rate exceeded/
            sleep delay
            delay *= 2
            if delay > max_delay
              delay = max_delay
            end
            retry
          end
        end
      end
    end
  end
end
