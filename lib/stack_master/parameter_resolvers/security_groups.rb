require 'stack_master/parameter_resolvers/security_group'

module StackMaster
  module ParameterResolvers
    class SecurityGroups
      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        sg_list = Array(value).map do |sg_name|
          SecurityGroup.new(@config, @stack_definition).resolve(sg_name)
        end

        sg_list
      end
    end
  end
end
