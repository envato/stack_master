module StackMaster
  module ParameterResolvers
    class ParameterStore < Resolver

      SecretNotFound = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        begin
          resp = ssm.get_parameter(
            name: value,
            with_decryption: true
          )
        rescue Aws::SSM::Errors::ParameterNotFound
          raise SecretNotFound, "Unable to find key #{value} in Parameter Store"
        end
        resp.parameter.value
      end

      private

      def ssm
        @ssm ||= Aws::SSM::Client.new(region: @stack_definition.region)
      end
    end
  end
end
