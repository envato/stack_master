require_relative 'empty_validator'
require_relative 'string_validator'
require_relative 'number_validator'
require_relative 'allowed_values_validator'
require_relative 'allowed_pattern_validator'
require_relative 'max_length_validator'
require_relative 'min_length_validator'
require_relative 'max_size_validator'
require_relative 'min_size_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class ValueValidatorFactory

        VALIDATORS_TYPES = [
            EmptyValidator,
            StringValidator,
            NumberValidator,
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

        def build
          VALIDATORS_TYPES.map {|validator| validator.new(@name, @definition, @parameter)}
        end

      end
    end
  end
end