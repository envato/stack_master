module StackMaster
  module TestDriver
    class S3
      def initialize
        reset
      end

      def set_region(_); end

      def reset
        @files = Hash.new { |hash, key| hash[key] = {} }
      end

      def upload_files(bucket: nil, prefix: nil, region: nil, files: {})
        return if files.empty?

        files.each do |template, file|
          object_key = [prefix, template].compact.join('/')
          @files[bucket][object_key] = file[:body]
        end
      end

      def url(bucket:, prefix:, region:, template:)
        ["https://s3-#{region}.amazonaws.com", bucket, prefix, template].compact.join('/')
      end

      # test only method
      def find_file(bucket:, object_key:)
        @files[bucket][object_key]
      end
    end
  end
end
