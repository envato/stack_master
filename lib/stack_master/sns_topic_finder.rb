module StackMaster
  class SnsTopicFinder
    TopicNotFound = Class.new(StandardError)

    def initialize(region)
      @resource = Aws::SNS::Resource.new({ region: region })
    end

    def find(reference)
      raise ArgumentError, 'SNS topic references must be non-empty strings' unless reference.is_a?(String) && !reference.empty?

      topic = @resource.topics.detect { |t| topic_name_from_arn(t.arn) == reference }

      raise TopicNotFound, "No topic with name #{reference} found" unless topic

      topic.arn
    end

    private

    def topic_name_from_arn(arn)
      arn.split(":")[5]
    end

  end
end
