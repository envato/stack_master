module StackMaster
  module ParameterResolvers
    class SecurityGroup
      def initialize(config, stack_definition, value)
        @config = config
        @stack_definition = stack_definition
        @value = value
      end

      def resolve
        security_group_finder.find(@value)
      end

      private

      def security_group_finder
        StackMaster::SecurityGroupFinder.new(@stack_definition.region)
      end
    end
  end
end
