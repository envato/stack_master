module StackMaster
  module ParameterResolvers
    class ParameterStore < Resolver

      ParameterNotFound = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        begin
          ssm = Aws::SSM::Client.new(region: @stack_definition.region)
          resp = ssm.get_parameter(
            name: value,
            with_decryption: true
          )
        rescue Aws::SSM::Errors::ParameterNotFound
          raise ParameterNotFound, "Unable to find #{value} in Parameter Store"
        end
        resp.parameter.value
      end
    end
  end
end
