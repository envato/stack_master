module StackMaster
  module ParameterResolvers
    class ParameterStore < Resolver

      ParameterNotFound = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @output_regex = %r{(?:(?<region>[^:]+):)?(?<key_name>.+)}
      end

      def resolve(value)
        region, key_name = parse!(value)
        begin
          ssm = Aws::SSM::Client.new(region: region)
          resp = ssm.get_parameter(
            name: key_name,
            with_decryption: true
          )
        rescue Aws::SSM::Errors::ParameterNotFound
          raise ParameterNotFound, "Unable to find #{key_name} in Parameter Store in #{region}"
        end
        resp.parameter.value
      end

      def parse!(value)
        if !value.is_a?(String) || !(match = @output_regex.match(value))
          raise ArgumentError, 'Parameter store names must be in the form of [region:]<parameter_name>'
        end

        [
          match[:region] || @stack_definition.region,
          match[:key_name]
        ]
      end
    end
  end
end
