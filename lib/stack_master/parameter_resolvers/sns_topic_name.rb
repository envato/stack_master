module StackMaster
  module ParameterResolvers
    class SnsTopicName < Resolver
      TopicNotFound = Class.new(StandardError)

      array_resolver

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
        @stacks = {}
      end

      def resolve(value)
        sns_topic_finder.find(value)
      rescue StackMaster::SnsTopicFinder::TopicNotFound => e
        raise TopicNotFound.new(e.message)
      end

      private

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end

      def sns_topic_finder
        StackMaster::SnsTopicFinder.new(@stack_definition.region)
      end
    end
  end
end
