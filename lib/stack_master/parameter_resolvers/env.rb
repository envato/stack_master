module StackMaster
  module ParameterResolvers
    class Env < Resolver
      array_resolver

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        ENV[value]
      end

    end
  end
end
