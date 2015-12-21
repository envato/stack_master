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

        files.each do |file|
          body = File.read(file)
          key = File.basename(file)
          key.prepend("#{prefix}/") if prefix

          put_object(
            bucket: bucket,
            key: key,
            body: body
          )
        end
      end

      def put_object(options)
        puts "Uploading #{options[:key]} to bucket #{options[:bucket]}..."
        s3.put_object(options)
      end

      def url(options)
        puts "Generating url for #{options.inspect}"
        s3_url(@region, options['bucket'], options['prefix'], options['template'])
      end

      def s3_url(region, bucket, prefix, file)
        "https://s3-#{region}.amazonaws.com/#{bucket}/#{prefix}/#{file}"
      end

      private

      def s3
        puts "Creating S3 client in #{@region}"
        @s3 ||= Aws::S3::Client.new(region: @region)
      end
    end
  end
end
