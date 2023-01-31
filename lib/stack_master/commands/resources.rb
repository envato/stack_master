require 'table_print'

module StackMaster
  module Commands
    class Resources
      include Command
      include Commander::UI

      def perform
        if stack_resources
          tp stack_resources, :logical_resource_id, :resource_type, :timestamp, :resource_status, :resource_status_reason, :description
        else
          failed("Stack doesn't exist")
        end
      end

      private

      def stack_resources
        @stack_resources ||= cf.describe_stack_resources({ stack_name: @stack_definition.stack_name }).stack_resources
      rescue Aws::CloudFormation::Errors::ValidationError
        nil
      end

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end
    end
  end
end
