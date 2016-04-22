module StackMaster
  module ParameterResolvers
    class AmiFinder
      def initialize(region)
        @region = region
      end

      def build_filters(value, prefix = nil)
        value.split(',').map do |name_with_value|
          name, value = name_with_value.strip.split('=')
          name = prefix ? "#{prefix}:#{name}" : name
          { name: name, values: [value] }
        end
      end

      def find_latest_ami(filters, owner = aws_account_id)
        images = ec2.describe_images(owners: [owner], filters: filters).images
        sorted_images = images.sort do |a, b|
          Time.parse(a.creation_date) <=> Time.parse(b.creation_date)
        end
        sorted_images.last
      end

      private

      def aws_account_id
        arn = iam.list_users.users.first.arn
        arn[/^arn:aws:iam::([0-9]{12}):/,1]
      end

      def ec2
        @ec2 ||= Aws::EC2::Client.new(region: @region)
      end

      def iam
        @iam ||= Aws::IAM::Client.new(region: @region)
      end
    end
  end
end