module StackMaster
  module ParameterResolvers
    class SnsTopicName
      TopicNotFound = Class.new(StandardError)

      def initialize(config, stack_definition, value)
        @config = config
        @stack_definition = stack_definition
        @value = value
        @stacks = {}
      end

      def resolve
        sns_topic_finder.find(@value)
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
