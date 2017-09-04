require_relative 'value_validator_factory'

module StackMaster
  module SparkleFormation
    module CompileTimeParameter

      class ParameterValidator

        def initialize(parameter_definition, parameter)
          @parameter_definition = parameter_definition
          @parameter = parameter
          @factory = ValueValidatorFactory.new(@parameter_definition, @parameter)
        end


        def validate
          validators = @factory.build_validators
          validators.map {|validator| validator.validate}.compact
        end

      end

    end
  end
end
