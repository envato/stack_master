module StackMaster
  module Commands
    class Resources
      include Command
      include Commander::UI

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
      end

      def perform
        if stack_resources
          tp stack_resources, :logical_resource_id, :resource_type, :timestamp, :resource_status, :resource_status_reason, :description
        else
          StackMaster.stdout.puts "Stack doesn't exist"
        end
      end

      private

      def stack_resources
        @stack_resources = cf.describe_stack_resources(stack_name: @stack_definition.stack_name).stack_resources
      rescue Aws::CloudFormation::Errors::ValidationError
        nil
      end

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end
    end
  end
end
