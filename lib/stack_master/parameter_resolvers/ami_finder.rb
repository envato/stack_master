module StackMaster
  module ParameterResolvers
    class AmiFinder
      def initialize(region)
        @region = region
        @owner = ['self']
      end

      def build_filters(value, prefix = nil)
        owner_id = []
        filters = value.split(',').map do |name_with_value|
          name, value = name_with_value.strip.split('=')
          owner_id.push value if name == 'owner_id'
          name = prefix ? "#{prefix}:#{name}" : name
          { name: name, values: [value] }
        end
        @owner = owner_id unless owner_id.empty?
        filters
      end

      def find_latest_ami(filters)
        images = ec2.describe_images(owners: @owner, filters: filters).images
        sorted_images = images.sort do |a, b|
          Time.parse(a.creation_date) <=> Time.parse(b.creation_date)
        end
        sorted_images.last
      end

      private

      def ec2
        @ec2 ||= Aws::EC2::Client.new(region: @region)
      end
    end
  end
end