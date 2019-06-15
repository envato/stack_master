module StackMaster
  module ParameterResolvers
    class LatestS3ObjectVersion< Resolver
      array_resolver class_name: 'LatestS3ObjectVersion'

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @s3_object_finder = S3ObjectFinder.new(@stack_definition.region)
      end

      def resolve(value)
        owners = Array(value.fetch('owners', 'self').to_s)
        filters = @s3_object_finder.build_filters_from_hash(value.fetch('filters'))
        @s3_object_finder.find_latest_file(filters, owners).try(:version_id)
      end
    end
  end
end
