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

    def underscore_to_hyphen(string)
      string.gsub('_', '-')
    end

    def underscore_keys_to_hyphen(hash)
      hash.inject({}) do |hash, (key, value)|
        hash[underscore_to_hyphen(key)] = value
        hash
      end
    end
  end
end
