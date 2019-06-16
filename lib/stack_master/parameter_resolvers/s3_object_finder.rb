module StackMaster
  module ParameterResolvers
    class S3ObjectFinder
      def initialize(region)
        @region = region
      end

      def build_filters_from_hash(hash)
        # create hash with key converted to symbol
        hash.map { |key, value| [key.to_sym, value.to_s] }.to_h
      end

      def find_latest_file(parameters)
        # STDERR.puts parameters
        file_versions = s3.list_object_versions(parameters)
        # STDERR.puts file_versions.versions
        sorted_file_versions = file_versions.versions.sort do |a, b|
          # STDERR.puts "last_modified=#{a.last_modified.class}"
          Time.parse(a.last_modified.to_s) <=> Time.parse(b.last_modified.to_s)
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
