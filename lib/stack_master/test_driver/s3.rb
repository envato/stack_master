module StackMaster
  module TestDriver
    class S3
      def initialize
        reset
      end

      def set_region(_)
      end

      def reset
        @files = Hash.new { |hash, key| hash[key] = Hash.new }
      end

      def upload_files(bucket: nil, prefix: nil, region: nil, files: {})
        return if files.empty?

        files.each do |template, (body, path)|
          object_key = [prefix, template].compact.join('/')
          @files[bucket][object_key] = body
        end
      end

      # test only method
      def find_file(bucket:, object_key:)
        @files[bucket][object_key]
      end
    end
  end
end
