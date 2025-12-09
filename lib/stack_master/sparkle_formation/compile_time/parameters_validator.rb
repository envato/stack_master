require_relative 'value_validator_factory'

module StackMaster
  module SparkleFormation
    module CompileTime
      class ParametersValidator
        def initialize(definitions, parameters)
          @definitions = definitions
          @parameters = parameters
        end

        def validate
          @definitions.each do |name, definition|
            parameter = @parameters[name.to_s.camelize]
            factory = ValueValidatorFactory.new(name, definition, parameter)
            value_validators = factory.build
            value_validators.each do |validator|
              validator.validate
              raise ArgumentError.new "Invalid compile time parameter: #{validator.error}" unless validator.is_valid
            end
          end
        end
      end
    end
  end
end
