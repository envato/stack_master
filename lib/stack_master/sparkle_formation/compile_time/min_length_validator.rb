require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class MinLengthValidator < ValueValidator
        KEY = :min_length

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          return true unless @definition[:type] == :string
          return true unless @definition.key?(KEY)

          invalid_values.empty?
        end

        def invalid_values
          values = build_values(@definition, @parameter)
          values.select { |value| value.length < @definition[KEY].to_i }
        end

        def create_error
          "#{@name}:#{invalid_values} must be at least #{KEY}:#{@definition[KEY]} characters"
        end
      end
    end
  end
end
