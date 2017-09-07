require_relative 'value_builder'

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
            state[name] = create_value(definition, parameter)
          end
          state
        end

        private

        def create_value(definition, parameter)
          ValueBuilder.new(definition, parameter).build
        end

      end
    end
  end
end
