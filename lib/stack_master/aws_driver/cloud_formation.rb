module StackMaster
  module AwsDriver
    class CloudFormation
      extend Forwardable

      def region
        @region ||= ENV['AWS_REGION'] || Aws.config[:region] || Aws.shared_config.region
      end

      def profile_name
        @profile_name ||= ENV['AWS_PROFILE'] || Aws.config[:profile_name]
      end

      def set_region(value)
        if region != value
          @region = value
          @cf = nil
        end
      end

      def set_profile(value)
        if profile_name != value
          @profile_name = value
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
                          :set_stack_policy,
                          :describe_stack_events,
                          :update_stack,
                          :create_stack,
                          :validate_template,
                          :describe_stacks

      private

      def cf
        @cf ||= begin
          params = {
            region: region,
            retry_limit: 10,
          }
          params[:credentials] = Aws::SharedCredentials.new(profile_name: profile_name) if profile_name

          Aws::CloudFormation::Client.new(params)
        end
      end
    end
  end
end
