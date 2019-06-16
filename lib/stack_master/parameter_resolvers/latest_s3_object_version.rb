module StackMaster
  module ParameterResolvers
    class LatestS3ObjectVersion < Resolver
      array_resolver class_name: 'LatestS3ObjectVersions'

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @s3_object_finder = S3ObjectFinder.new(@stack_definition.region)
      end

      def resolve(parameters)
        parameters_map = @s3_object_finder.build_filters_from_hash(parameters)
        s3object = @s3_object_finder.find_latest_file(parameters_map)
        # debugging of s3object
        # STDERR.puts "s3object type=#{s3object.class}"
        # STDERR.puts "s3object[:version_id]=#{s3object.try(:version_id)}"
        s3object.try(:version_id)
      end 
    end
  end
end
