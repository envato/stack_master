module StackMaster
  module AwsDriver
    class CloudFormation
      extend Forwardable

      def set_region(region)
        @region = region
        @cf = nil
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
                          :validate_template,
                          :describe_stacks

      private

      def cf
        @cf ||= Aws::CloudFormation::Client.new(region: @region, retry_limit: 10)
      end

    end
  end
end
