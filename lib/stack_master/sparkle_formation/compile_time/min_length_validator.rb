require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class MinLengthValidator < ValueValidator

        KEY = :min_length

        def initialize(name, parameter_definition, value)
          @name = name
          @parameter_definition = parameter_definition
          @value = value
        end

        private

        def check_is_valid
          return true unless @parameter_definition.key?(KEY)
          !value_is_less_than_min_length?
        end

        def value_is_less_than_min_length?
          @value.length < @parameter_definition[KEY].to_i
        end

        def create_error
          "#{@name}:#{@value} must be at least #{KEY}:#{@parameter_definition[KEY]} characters"
        end

      end
    end
  end
end
