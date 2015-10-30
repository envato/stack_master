module StackMaster
  module Commands
    class Status
      include Command

      def initialize(config)
        @config = config
      end

      def perform
        tp.set :io, $stdout
        tp @config.stack_definitions.stacks.map { |stack_definition| get_status(stack_definition) }
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
          different = body_different?(proposed_stack, stack) || params_different?(proposed_stack, stack)
        rescue Aws::CloudFormation::Errors::ValidationError
          stack_status = "missing"
          different = true
        end

        { region: region, stack_name: stack_name, stack_status: stack_status, different: different ? "Yes" : "No" }
      end

      def body_different?(proposed_stack, stack)
        body1 = JSON.pretty_generate(stack.template_hash)
        body2 = JSON.pretty_generate(JSON.parse(proposed_stack.template_body))
        Diffy::Diff.new(body1, body2, {}).to_s != ''
      end

      def params_different?(proposed_stack, stack)
        params1 = JSON.pretty_generate(sort_params(proposed_stack.parameters))
        params2 = JSON.pretty_generate(sort_params(stack.parameters))
        Diffy::Diff.new(params1, params2, {}).to_s != ''
      end
    end
  end
end
