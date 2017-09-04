require_relative 'value_validator_factory'

module StackMaster
  module SparkleFormation
    module CompileTimeParameter

      class ParameterValidator

        def initialize(name, definition, parameter)
          @factory = ValueValidatorFactory.new(name, definition, parameter)
        end


        def validate
          validators = @factory.build_validators
          invalid_validator = validators.detect{|validator| !validator.is_valid?}
          invalid_validator.error if invalid_validator
        end

      end

    end
  end
end
