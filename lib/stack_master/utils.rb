module StackMaster
  module Utils
    extend self

    def hash_to_aws_parameters(params)
      params.inject([]) do |params, (key, value)|
        params << { parameter_key: key, parameter_value: value }
        params
      end
    end

    def hash_to_aws_tags(tags)
      return [] if tags.nil?
      tags.inject([]) do |aws_tags, (key, value)|
        aws_tags << { key: key, value: value }
        aws_tags
      end
    end
  end
end
