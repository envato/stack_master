module StackMaster
  module ParameterResolvers
    class AmiFinder
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
        hash.map { |key, value| { name: key, values: Array(value.to_s) } }
      end

      def find_latest_ami(filters, owners = ['self'])
        images = ec2.describe_images({ owners: owners, filters: filters }).images
        sorted_images = images.sort do |a, b|
          Time.parse(a.creation_date) <=> Time.parse(b.creation_date)
        end
        sorted_images.last
      end

      private

      def ec2
        @ec2 ||= Aws::EC2::Client.new({ region: @region })
      end
    end
  end
end
