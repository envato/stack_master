module StackMaster
  module ParameterResolvers
    class LatestContainer < Resolver
      array_resolver class_name: 'LatestContainers'

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(parameters)
        if parameters['repository_name'].nil?
          raise ArgumentError, "repository_name parameter is required but was not supplied"
        end

        @region = parameters['region'] || @stack_definition.region
        ecr_client = Aws::ECR::Client.new({ region: @region })

        images = fetch_images(parameters['repository_name'], parameters['registry_id'], ecr_client)

        unless parameters['tag'].nil?
          images.select! { |image| image.image_tags.any? { |tag| tag == parameters['tag'] } }
        end
        images.sort! { |image_x, image_y| image_y.image_pushed_at <=> image_x.image_pushed_at }

        return nil if images.empty?

        latest_image = images.first

        # aws_account_id.dkr.ecr.region.amazonaws.com/repository@sha256:digest
        "#{latest_image.registry_id}.dkr.ecr.#{@region}.amazonaws.com/#{parameters['repository_name']}@#{latest_image.image_digest}"
      end

      private

      def fetch_images(repository_name, registry_id, ecr)
        images = []
        next_token = nil
        while
          resp = ecr.describe_images({
            repository_name: repository_name,
            registry_id: registry_id,
            next_token: next_token,
            filter: {
              tag_status: "TAGGED",
            },
          })

          images += resp.image_details
          next_token = resp.next_token
          break if next_token.nil?
        end
        images
      end
    end
  end
end
