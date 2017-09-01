require 'bogo'

module StackMaster
  module SparkleFormation

    # Helper utility for validating stack parameters
    class ParameterValidator

      include Bogo::AnimalStrings

      # HOT parameter mapping
      HEAT_CONSTRAINT_MAP = {
          'MaxLength' => [:length, :max],
          'MinLength' => [:length, :min],
          'MaxValue' => [:range, :max],
          'MinValue' => [:range, :min],
          'AllowedValues' => [:allowed_values],
          'AllowedPattern' => [:allowed_pattern]
      }

      # GCDM parameter mapping
      GOOGLE_CONSTRAINT_MAP = {
          'AllowedPattern' => [:pattern],
          'MaxValue' => [:maximum],
          'MinValue' => [:minimum]
      }

      # Parameter mapping identifier and content
      PARAMETER_DEFINITION_MAP = {
          'constraints' => HEAT_CONSTRAINT_MAP
      }

      # Supported parameter validations
      PARAMETER_VALIDATIONS = [
          'allowed_values',
          'allowed_pattern',
          'max_length',
          'min_length',
          'max_size',
          'min_size'
      ]

      # Validate a parameters
      #
      # @param value [Object] value for parameter
      # @param parameter_definition [Hash]
      # @option parameter_definition [Array<String>] 'AllowedValues'
      # @option parameter_definition [String] 'AllowedPattern'
      # @option parameter_definition [String, Integer] 'MaxLength'
      # @option parameter_definition [String, Integer] 'MinLength'
      # @option parameter_definition [String, Integer] 'MaxValue'
      # @option parameter_definition [String, Integer] 'MinValue'
      # @return [TrueClass, Array<String>] true if valid. array of string errors if invalid
      def self.validate_parameter(value, parameter_definition)
        return [[:blank, 'Value cannot be blank']] if value.to_s.strip.empty?
        parameter_definition = reformat_definition(parameter_definition)
        value_list = list_type?(parameter_definition.fetch('Type', parameter_definition['type'].to_s)) ? value.to_s.split(',') : [value]
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

      # Reformat parameter definition with proper keys to allow
      # validation for templates different parameter definition
      # layout
      #
      # @param pdef [Hash]
      # @return [Hash]
      def self.reformat_definition(pdef)
        new_def = pdef
        PARAMETER_DEFINITION_MAP.each do |ident, mapping|
          if (pdef[ident])
            new_def = Smash.new
            mapping.each do |new_key, current_path|
              if (pdef.get(*current_path))
                new_def[new_key] = pdef.get(*current_path)
              end
            end
          end
        end
        new_def
      end

      # Parameter is within allowed values
      #
      # @param value [String]
      # @param pdef [Hash] parameter definition
      # @option pdef [Array<String>] 'AllowedValues'
      # @return [TrueClass, String]
      def self.allowed_values(value, pdef)
        if (pdef.include?(value))
          true
        else
          "Not an allowed value: #{pdef.join(', ')}"
        end
      end

      # Parameter matches allowed pattern
      #
      # @param value [String]
      # @param pdef [Hash] parameter definition
      # @option pdef [String] 'AllowedPattern'
      # @return [TrueClass, String]
      def self.allowed_pattern(value, pdef)
        if (value.match(%r{#{pdef}}))
          true
        else
          "Not a valid pattern. Must match: #{pdef}"
        end
      end

      # Parameter length is less than or equal to max length
      #
      # @param value [String, Integer]
      # @param pdef [Hash] parameter definition
      # @option pdef [String] 'MaxLength'
      # @return [TrueClass, String]
      def self.max_length(value, pdef)
        if (value.length <= pdef.to_i)
          true
        else
          "Value must not exceed #{pdef} characters"
        end
      end

      # Parameter length is greater than or equal to min length
      #
      # @param value [String]
      # @param pdef [Hash] parameter definition
      # @option pdef [String] 'MinLength'
      # @return [TrueClass, String]
      def self.min_length(value, pdef)
        if (value.length >= pdef.to_i)
          true
        else
          "Value must be at least #{pdef} characters"
        end
      end

      # Parameter value is less than or equal to max value
      #
      # @param value [String]
      # @param pdef [Hash] parameter definition
      # @option pdef [String] 'MaxValue'
      # @return [TrueClass, String]
      def self.max_size(value, pdef)
        if (value.to_i <= pdef.to_i)
          true
        else
          "Value must not be greater than #{pdef}"
        end
      end

      # Parameter value is greater than or equal to min value
      #
      # @param value [String]
      # @param pdef [Hash] parameter definition
      # @option pdef [String] 'MinValue'
      # @return [TrueClass, String]
      def self.min_size(value, pdef)
        if (value.to_i >= pdef.to_i)
          true
        else
          "Value must not be less than #{pdef}"
        end
      end

      # Check if type is a list type
      #
      # @param type [String]
      # @return [TrueClass, FalseClass]
      def self.list_type?(type)
        type = type.downcase
        type.start_with?('comma') || type.start_with?('list<')
      end

    end
  end
end
