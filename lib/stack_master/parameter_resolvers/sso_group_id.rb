module StackMaster
  module ParameterResolvers
    class SsoGroupId < Resolver
      InvalidParameter = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        raise InvalidParameter, "sso_identity_store_id must be set in stack_master.yml when using sso_group_id resolver" unless @config.sso_identity_store_id
      end

      def resolve(value)
        sso_group_id_finder.find(value, @config.sso_identity_store_id)
      end

    private
      def sso_group_id_finder
        StackMaster::SsoGroupIdFinder.new(@stack_definition.region)
      end
    end
  end
end
