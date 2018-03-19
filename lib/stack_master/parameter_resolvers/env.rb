module StackMaster
  module ParameterResolvers
    class Env < Resolver

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        environment_variable = ENV[value]
        raise ArgumentError, "The environment variable #{value} is not set" if environment_variable.nil?
        environment_variable
      end

    end
  end
end
