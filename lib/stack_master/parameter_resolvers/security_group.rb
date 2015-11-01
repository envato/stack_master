module StackMaster
  module ParameterResolvers
    class SecurityGroup
      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        security_group_finder.find(value)
      end

      private

      def security_group_finder
        StackMaster::SecurityGroupFinder.new(@stack_definition.region)
      end
    end
  end
end
