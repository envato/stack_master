module StackMaster
  module ParameterResolvers
    class SsoGroupId < Resolver
      InvalidParameter = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        sso_group_id_finder.find(value)
      end

    private
      def sso_group_id_finder
        StackMaster::SsoGroupIdFinder.new()
      end
    end
  end
end
