require 'digest/md5'

module StackMaster
  module AwsDriver
    class S3ConfigurationError < StandardError; end

    class S3
      def set_region(region)
        @region = region
        @s3 = nil
      end

      def upload_files(options)
        bucket = options.fetch(:bucket) { raise StackMaster::AwsDriver::S3ConfigurationError, 'A bucket must be specified in order to use S3' }
        prefix = options[:prefix]
        bucket_region = options.fetch(:region, @region)
        files = options.fetch(:files, [])

        return if files.empty?

        set_region(bucket_region) if bucket_region

        current_objects = list_objects(
          prefix: prefix,
          bucket: bucket
        ).map(&:contents).flatten.inject({}){|h,obj|
          h.merge(obj.key => obj)
        }

        files.each do |template, file|
          body = file[:body]
          file = file[:path]
          key = template.dup
          key.prepend("#{prefix}/") if prefix
          raw_template_md5 = Digest::MD5.file(file).to_s
          compiled_template_md5 = Digest::MD5.hexdigest(body).to_s
          s3_md5 = current_objects[key] ? current_objects[key].etag.gsub("\"", '') : nil

          next if [raw_template_md5, compiled_template_md5].include?(s3_md5)
          StackMaster.stdout.puts "Uploading #{file} to bucket #{options[:bucket]}/#{key}..."

          put_object(
            bucket: bucket,
            key: key,
            body: body,
            metadata: { md5: compiled_template_md5 }
          )
        end
      end

      def list_objects(options)
        s3.list_objects(options)
      end

      def put_object(options)
        s3.put_object(options)
      end

      def url(bucket: bucket, prefix: prefix, region: region, template: template)
        if region == 'us-east-1'
          ["https://s3.amazonaws.com", bucket, prefix, template].compact.join('/')
        else
          ["https://s3-#{region}.amazonaws.com", bucket, prefix, template].compact.join('/')
        end
      end

      private

      def s3
        @s3 ||= Aws::S3::Client.new(region: @region)
      end
    end
  end
end
