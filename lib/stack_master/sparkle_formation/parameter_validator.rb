module StackMaster
  module SparkleFormation

    # Helper utility for validating stack parameters
    class ParameterValidator

      # Supported parameter validations
      PARAMETER_VALIDATIONS = %w(allowed_values allowed_pattern max_length min_length max_size min_size)

      def self.validate_parameter(value, parameter_definition)
        if value.is_a?(Enumerable)
          validate_list(value, parameter_definition)
        else
          validate(value, parameter_definition)
        end
      end

      def self.validate_list(value_list, parameter_definition)
        result = []
        value_list.each {|value| result += validate(value, parameter_definition)}
        result
      end

      def self.validate(value, parameter_definition)
        result = []
        PARAMETER_VALIDATIONS.each do |validator_key|
          valid_key = parameter_definition.keys.detect {|pdef_key| pdef_key == validator_key}
          if valid_key
               if value.to_s.strip.empty?
                result << [validator_key, 'Value cannot be blank']
              else
                unless self.send("#{validator_key}?", value, parameter_definition[valid_key])
                  message = self.send("#{validator_key}_message", parameter_definition[valid_key])
                  result << [validator_key, message]
                end
              end
           end
        end
        result
      end

      def self.allowed_values?(value, pdef)
        pdef.include?(value)
      end

      def self.allowed_values_message(pdef)
        "Not an allowed value: #{pdef.join(', ')}"
      end

      def self.allowed_pattern?(value, pdef)
        value.match(%r{#{pdef}})
      end

      def self.allowed_pattern_message(pdef)
        "Not a valid pattern. Must match: #{pdef}"
      end

      def self.max_length?(value, pdef)
        value.length <= pdef.to_i
      end

      def self.max_length_message(pdef)
        "Value must not exceed #{pdef} characters"
      end

      def self.min_length?(value, pdef)
        value.length >= pdef.to_i
      end

      def self.min_length_message(pdef)
        "Value must be at least #{pdef} characters"
      end

      def self.max_size?(value, pdef)
        value.to_i <= pdef.to_i
      end

      def self.max_size_message(pdef)
        "Value must not be greater than #{pdef}"
      end

      def self.min_size?(value, pdef)
        value.to_i >= pdef.to_i
      end

      def self.min_size_message(pdef)
        "Value must not be less than #{pdef}"
      end

    end
  end
end

