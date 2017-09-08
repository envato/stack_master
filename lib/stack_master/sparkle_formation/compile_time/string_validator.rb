require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class StringValidator < ValueValidator

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          return true unless @definition[:type] == :string
          invalid_values.empty?
        end

        def invalid_values
          values = build_values(@definition, @parameter)
          values.reject {|value| value.is_a?(String)}
        end

        def create_error
          "#{@name}:#{invalid_values} are not Strings"
        end

      end
    end
  end
end
