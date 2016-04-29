module StackMaster
  module ParameterResolvers
    class LatestAmi < Resolver
      array_resolver class_name: 'LatestAmis'

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @ami_finder = AmiFinder.new(@stack_definition.region)
      end

      def resolve(value)
        case value
        when String
          owners = ['self']
          filters = @ami_finder.build_filters_from_string(value)
        when Hash
          owners = Array(value.delete('owner_id').to_s || 'self')
          filters = @ami_finder.build_filters_from_hash(value)
        end
        @ami_finder.find_latest_ami(filters, owners).try(:image_id)
      end
    end
  end
end
