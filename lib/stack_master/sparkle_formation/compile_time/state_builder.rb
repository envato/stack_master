require_relative 'parameter_builder'

module StackMaster
  module SparkleFormation
    module CompileTime
      class StateBuilder

        def initialize(definitions, parameters)
          @definitions = definitions
          @parameters = parameters
        end

        def build
          state = {}
          @definitions.each do |name, definition|
            parameter_key = name.to_s.camelize
            parameter = @parameters[parameter_key]
            state[name] = create_parameter(definition, parameter)
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
