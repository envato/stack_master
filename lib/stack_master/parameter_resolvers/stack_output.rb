module StackMaster
  module ParameterResolvers
    class StackOutput
      StackNotFound = Class.new(StandardError)
      StackOutputNotFound = Class.new(StandardError)

      def initialize(region, value)
        @region = region
        @value = value
        @stacks = {}
      end

      def resolve
        validate_value!
        stack_name, output_name = @value.split('/')
        stack = @stacks.fetch(stack_name) { Stack.find(@region, stack_name) }
        if stack
          output = stack.outputs.find { |output| output.output_key == output_name.camelize }
          if output
            output.output_value
          else
            raise StackOutputNotFound, "Stack exists (#{stack_name}), but output does not: #{output_name}"
          end
        else
          raise StackNotFound, "Stack in StackOutput not found: #{@value}"
        end
      end

      private

      def cf
        @cf ||= Aws::CloudFormation::Client.new(region: @region)
      end

      def validate_value!
        if !@value.is_a?(String) || !@value.include?('/')
          raise ArgumentError, 'Stack output values must be in the form of stack-name/output-name'
        end
      end
    end
  end
end
