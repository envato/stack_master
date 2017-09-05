require_relative 'parameter_builder'

module StackMaster
  module SparkleFormation
    module CompileTime
      class StateBuilder

        def initialize(sparkle_template, parameters)
          @sparkle_template = sparkle_template
          @parameters = parameters
        end

        def build
          state = {}
          @sparkle_template.parameters.each do |compile_parameter_name, definition|
            parameter_name = compile_parameter_name.to_s.camelize
            parameter = @parameters[parameter_name]
            state[compile_parameter_name] = create_parameter(definition, parameter)
          end
          state
        end

        private

        def create_parameter(definition, parameter)
          ParameterBuilder.new(definition, parameter).build
        end

      end
    end
  end
end
