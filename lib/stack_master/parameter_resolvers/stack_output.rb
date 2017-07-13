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
        @cf_drivers = {}
        @output_regex = %r{(?:(?<region>[^:]+):)?(?<stack_name>[^:/]+)/(?<output_name>.+)}
      end

      def resolve(value)
        region, stack_name, output_name = parse!(value)
        stack = find_stack(stack_name, region)
        if stack
          output = stack.outputs.find { |stack_output| stack_output.output_key == output_name.camelize }
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

      def parse!(value)
        if !value.is_a?(String) || !(match = @output_regex.match(value))
          raise ArgumentError, 'Stack output values must be in the form of [region:]stack-name/output_name'
        end

        [
          match[:region] || cf.region,
          match[:stack_name],
          match[:output_name]
        ]
      end

      def find_stack(stack_name, region)
        unaliased_region = @config.unalias_region(region)
        stack_key = stack_key(stack_name, unaliased_region)

        @stacks.fetch(stack_key) do
          regional_cf = cf_for_region(unaliased_region)
          cf_stack = regional_cf.describe_stacks(stack_name: stack_name).stacks.first
          @stacks[stack_key] = cf_stack
        end
      end

      def stack_key(stack_name, region)
        "#{region}:#{stack_name}"
      end

      def cf_for_region(region)
        return cf if cf.region == region

        @cf_drivers.fetch(region) do
          cloud_formation_driver = cf.class.new
          cloud_formation_driver.set_region(region)
          @cf_drivers[region] = cloud_formation_driver
        end
      end
    end
  end
end
