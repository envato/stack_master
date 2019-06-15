module StackMaster
  module ParameterResolvers
    class S3ObjectFinder
      def initialize(region)
        @region = region
      end

      def build_filters_from_string(value, prefix = nil)
        filters = value.split(',').map do |name_with_value|
          name, value = name_with_value.strip.split('=')
          name = prefix ? "#{prefix}:#{name}" : name
          { name: name, values: [value] }
        end
        filters
      end

      def build_filters_from_hash(hash)
        hash.map { |key, value| {name: key, values: Array(value.to_s)}}
      end

      def find_latest_file(filters, owners = ['self'])
        fileversions = s3.list_object_versions(owners: owners, filters: filters).images
        sorted_file_versions = file_versions.sort do |a, b|
          Time.parse(a.last_modified) <=> Time.parse(b.last_modified)
        end
        sorted_file_versions.last
      end

      private

      def s3
        @s3 ||= Aws::S3::Client.new(region: @region)
      end
    end
  end
end
