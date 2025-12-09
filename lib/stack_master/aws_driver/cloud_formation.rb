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

      def_delegators(
        :cf,
        :create_change_set,
        :describe_change_set,
        :execute_change_set,
        :delete_change_set,
        :delete_stack,
        :cancel_update_stack,
        :describe_stack_resources,
        :get_template,
        :get_stack_policy,
        :set_stack_policy,
        :describe_stack_events,
        :update_stack,
        :create_stack,
        :validate_template,
        :describe_stacks,
        :detect_stack_drift,
        :describe_stack_drift_detection_status,
        :describe_stack_resource_drifts
      )

      private

      def cf
        @cf ||= Aws::CloudFormation::Client.new({ region: region, retry_limit: 10 })
      end
    end
  end
end
