module StackMaster
  module AwsDriver
    class CloudFormation
      def set_region(region)
        @region = region
        @cf = nil
      end

      def describe_stacks(options)
        cf.describe_stacks(options)
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
    end
  end
end
