module StackMaster
  module ParameterResolvers
    class ParameterStore < Resolver
      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        resp = ssm.get_parameter(
          name: value,
          with_decryption: true
        )
        resp.parameter.value
      end

      private

      def ssm
        @ssm ||= Aws::SSM::Client.new(region: @stack_definition.region)
      end
    end
  end
end
