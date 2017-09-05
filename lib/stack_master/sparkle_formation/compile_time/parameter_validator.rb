require_relative 'value_validator_factory'

module StackMaster
  module SparkleFormation
    module CompileTime
      class ParameterValidator < ValueValidator

        def initialize(name, definition, parameter)
          @factory = ValueValidatorFactory.new(name, definition, parameter)
        end

        def validate
          validators = @factory.build_validators
          validators.each do |validator|
            validator.validate
            @is_valid = validator.is_valid
            @error = validator.error unless @is_valid
            return unless @is_valid
          end
        end

      end
    end
  end
end
