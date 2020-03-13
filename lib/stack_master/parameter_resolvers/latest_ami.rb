module StackMaster
  module ParameterResolvers
    class LatestAmi < Resolver
      array_resolver class_name: 'LatestAmis'

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        owners = Array(value.fetch('owners', 'self').to_s)
        ami_finder = AmiFinder.new(@stack_definition.region)
        filters = ami_finder.build_filters_from_hash(value.fetch('filters'))
        ami_finder.find_latest_ami(filters, owners)&.image_id
      end
    end
  end
end
