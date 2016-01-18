module StackMaster
  module ParameterResolvers
    class StackOutput < Resolver
      StackNotFound = Class.new(StandardError)
      StackOutputNotFound = Class.new(StandardError)

      array_resolver

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @stacks = {}
      end

      def resolve(value)
        validate_value!(value)
        stack_name, output_name = value.split('/')
        stack = find_stack(stack_name)
        if stack
          output = stack.outputs.find { |output| output.output_key == output_name.camelize }
          if output
            output.output_value
          else
            raise StackOutputNotFound, "Stack exists (#{stack_name}), but output does not: #{output_name}"
          end
        else
          raise StackNotFound, "Stack in StackOutput not found: #{value}"
        end
      end

      private

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end

      def validate_value!(value)
        if !value.is_a?(String) || !value.include?('/')
          raise ArgumentError, 'Stack output values must be in the form of stack-name/output-name'
        end
      end

      def find_stack(stack_name)
        @stacks.fetch(stack_name) do
          cf_stack = cf.describe_stacks(stack_name: stack_name).stacks.first
          @stacks[stack_name] = cf_stack
        end
      end

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end
    end
  end
end
