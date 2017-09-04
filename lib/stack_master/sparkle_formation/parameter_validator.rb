require 'bogo'

module StackMaster
  module SparkleFormation

    # Helper utility for validating stack parameters
    class ParameterValidator

      include Bogo::AnimalStrings

      # Supported parameter validations
      PARAMETER_VALIDATIONS = %w(allowed_values allowed_pattern max_length min_length max_size min_size)

      def self.validate_parameter(value, parameter_definition)
        return [[:blank, 'Value cannot be blank']] if value.to_s.strip.empty?
        value_list = [value]
        result = PARAMETER_VALIDATIONS.map do |validator_key|
          valid_key = parameter_definition.keys.detect do |pdef_key|
            pdef_key.downcase.gsub('_', '') == validator_key.downcase.gsub('_', '')
          end
          if (valid_key)
            value_list.map do |value|
              res = self.send(validator_key, value, parameter_definition[valid_key])
              res == true ? true : [validator_key, res]
            end
          else
            true
          end
        end.flatten(1)
        result.delete_if {|x| x == true}
        result.empty? ? true : result
      end

      def self.allowed_values(value, pdef)
        if pdef.include?(value)
          true
        else
          "Not an allowed value: #{pdef.join(', ')}"
        end
      end

      def self.allowed_pattern(value, pdef)
        if value.match(%r{#{pdef}})
          true
        else
          "Not a valid pattern. Must match: #{pdef}"
        end
      end

      def self.max_length(value, pdef)
        if value.length <= pdef.to_i
          true
        else
          "Value must not exceed #{pdef} characters"
        end
      end

      def self.min_length(value, pdef)
        if value.length >= pdef.to_i
          true
        else
          "Value must be at least #{pdef} characters"
        end
      end

      def self.max_size(value, pdef)
        if value.to_i <= pdef.to_i
          true
        else
          "Value must not be greater than #{pdef}"
        end
      end

      def self.min_size(value, pdef)
        if value.to_i >= pdef.to_i
          true
        else
          "Value must not be less than #{pdef}"
        end
      end

    end
  end
end
