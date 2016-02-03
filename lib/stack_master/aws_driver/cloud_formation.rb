module StackMaster
  module AwsDriver
    class CloudFormation
      def set_region(region)
        @region = region
        @cf = nil
      end

      def delete_stack(options)
        cf.delete_stack(options)
      end

      def describe_stacks(options)
        retry_with_backoff do
          cf.describe_stacks(options)
        end
      end

      def cancel_update_stack(options)
        cf.cancel_update_stack(options)
      end

      def describe_stack_resources(options)
        cf.describe_stack_resources(options)
      end

      def get_template(options)
        cf.get_template(options)
      end

      def get_stack_policy(options)
        cf.get_stack_policy(options)
      end

      def describe_stack_events(options)
        cf.describe_stack_events(options)
      end

      def update_stack(options)
        cf.update_stack(options)
      end

      def create_stack(options)
        cf.create_stack(options)
      end

      def validate_template(options)
        cf.validate_template(options)
      end

      private

      def cf
        @cf ||= Aws::CloudFormation::Client.new(region: @region)
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
