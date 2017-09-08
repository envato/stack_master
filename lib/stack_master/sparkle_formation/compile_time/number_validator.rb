require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class NumberValidator < ValueValidator

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          return true unless @definition[:type] == :number
          invalid_values.empty?
        end

        def invalid_values
          values = build_values(@definition, @parameter)
          #TODO: check value is a number
          values
        end

        def create_error
          "#{@name}:#{invalid_values} are not Numbers"
        end

      end
    end
  end
end
