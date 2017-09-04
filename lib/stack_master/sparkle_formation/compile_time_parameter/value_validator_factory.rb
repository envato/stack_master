require_relative 'empty_validator'
require_relative 'allowed_values_validator'
require_relative 'allowed_pattern_validator'
require_relative 'max_length_validator'
require_relative 'min_length_validator'
require_relative 'max_size_validator'
require_relative 'min_size_validator'

module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class ValueValidatorFactory

        VALIDATORS_TYPES = [
            EmptyValidator,
            AllowedValuesValidator,
            AllowedPatternValidator,
            MaxLengthValidator,
            MinLengthValidator,
            MaxSizeValidator,
            MinSizeValidator]

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        def build_validators
          values_to_validate = create_values_to_validate
          values_to_validate.map {|value| create_validators(value)}.flatten
        end

        private

        def create_values_to_validate
          @parameter.is_a?(Enumerable) ? @parameter : [@parameter]
        end

        def create_validators(value)
          VALIDATORS_TYPES.map {|validator| validator.new(@name, @definition, value)}
        end

      end
    end
  end
end