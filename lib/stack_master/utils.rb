module StackMaster
  module Utils
    module Initializable
      def initialize(attributes = {})
        self.attributes = attributes
      end

      def attributes=(attributes)
        attributes.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      end
    end

    extend self

    def change_extension(file_name, extension)
      [
        File.basename(file_name, '.*'),
        extension
      ].join('.')
    end

    def hash_to_aws_parameters(params)
      params.each_with_object([]) do |(key, value), params|
        params << { parameter_key: key, parameter_value: value }
      end
    end

    def hash_to_aws_tags(tags)
      return [] if tags.nil?

      tags.each_with_object([]) do |(key, value), aws_tags|
        aws_tags << { key: key, value: value }
      end
    end

    def underscore_to_hyphen(string)
      string.to_s.gsub('_', '-')
    end

    def underscore_keys_to_hyphen(hash)
      hash.each_with_object({}) do |(key, value), hash|
        hash[underscore_to_hyphen(key)] = value
      end
    end
  end
end
