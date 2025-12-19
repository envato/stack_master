require 'digest/md5'

module StackMaster
  module AwsDriver
    class S3ConfigurationError < StandardError; end

    class S3
      def set_region(region)
        @region = region
        @s3 = nil
      end

      def upload_files(bucket: nil, prefix: nil, region: nil, files: {})
        unless bucket
          raise StackMaster::AwsDriver::S3ConfigurationError, 'A bucket must be specified in order to use S3'
        end

        return if files.empty?

        s3 = new_s3_client(region: region)

        current_objects = s3.list_objects(
          {
            prefix: prefix,
            bucket: bucket
          }
        ).map(&:contents).flatten.inject({}) do |h, obj|
          h.merge(obj.key => obj)
        end

        StackMaster.stdout.puts 'Uploading files to S3:'

        files.each do |template, file|
          body = file.fetch(:body)
          path = file.fetch(:path)
          object_key = template.dup
          object_key.prepend("#{prefix}/") if prefix
          compiled_template_md5 = Digest::MD5.hexdigest(body).to_s
          s3_md5 = current_objects[object_key] ? current_objects[object_key].etag.gsub('"', '') : nil

          next if compiled_template_md5 == s3_md5

          s3_uri = "s3://#{bucket}/#{object_key}"
          StackMaster.stdout.print "- #{File.basename(path)} => #{s3_uri} "

          s3.put_object(
            {
              bucket: bucket,
              key: object_key,
              body: body,
              metadata: { md5: compiled_template_md5 }
            }
          )
          StackMaster.stdout.puts 'done.'
        end
      end

      def url(bucket:, prefix:, region:, template:)
        if region == 'us-east-1'
          ['https://s3.amazonaws.com', bucket, prefix, template].compact.join('/')
        elsif region.start_with? 'cn-'
          ["https://s3.#{region}.amazonaws.com.cn", bucket, prefix, template].compact.join('/')
        else
          ["https://s3-#{region}.amazonaws.com", bucket, prefix, template].compact.join('/')
        end
      end

      private

      def new_s3_client(region: nil)
        Aws::S3::Client.new({ region: region || @region })
      end
    end
  end
end
