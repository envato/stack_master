module StackMaster
  module Commands
    class Status
      include Command

      def initialize(config)
        @config = config
      end

      def perform
        tp.set :io, StackMaster.stdout
        tp @config.stacks.map { |stack_definition| get_status(stack_definition) }
      end

      private

      def sort_params(hash)
        hash.sort.to_h
      end

      def get_status(stack_definition)
        region = stack_definition.region
        stack_name = stack_definition.stack_name
        begin
          driver = StackMaster.cloud_formation_driver
          driver.set_region(region)
          stack_events = driver.describe_stack_events({stack_name: stack_name}).stack_events
          stack_status = stack_events.first.resource_status
          stack = Stack.find(region, stack_name)
          proposed_stack = Stack.generate(stack_definition, @config)
          differ = StackMaster::StackDiffer.new(proposed_stack, stack)
          different = differ.body_different? || differ.params_different?
        rescue Aws::CloudFormation::Errors::ValidationError
          stack_status = "missing"
          different = true
        end

        { region: region, stack_name: stack_name, stack_status: stack_status, different: different ? "Yes" : "No" }
      end

    end
  end
end
