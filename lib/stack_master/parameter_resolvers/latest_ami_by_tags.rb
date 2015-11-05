module StackMaster
  module ParameterResolvers
    class LatestAmiByTags
      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        filters = build_filters(value)
        find_latest_ami(filters).try(:image_id)
      end

      private

      def ec2
        @ec2 ||= Aws::EC2::Client.new
      end

      def build_filters(value)
        value.split(',').map do |tag_with_value|
          tag, value = tag_with_value.strip.split('=')
          { name: "tag:#{tag}", values: [value] }
        end
      end

      def find_latest_ami(filters)
        images = ec2.describe_images(filters: filters).images
        sorted_images = images.sort do |a, b|
          Time.parse(a.creation_date) <=> Time.parse(b.creation_date)
        end
        sorted_images.last
      end
    end
  end
end
