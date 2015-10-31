module StackMaster
  module ParameterResolvers
    class StackOutput
      StackNotFound = Class.new(StandardError)
      StackOutputNotFound = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @stacks = {}
      end

      def resolve(value)
        validate_value!(value)
        stack_name, output_name = value.split('/')
        stack = @stacks.fetch(stack_name) { @stacks[stack_name] = Stack.find(@stack_definition.region, stack_name) }
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
    end
  end
end
