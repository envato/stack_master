require_relative 'validator'

module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MaxLengthValidator < Validator

        KEY = :max_length

        def initialize(name, parameter_definition, value)
          @name = name
          @parameter_definition = parameter_definition
          @value = value
        end

        private

        def check_is_valid
          return true unless @parameter_definition.key?(KEY)
          !value_is_greater_than_max_length?
        end

        def value_is_greater_than_max_length?
          @value.length > @parameter_definition[KEY].to_i
        end

        def create_error
          "#{@name}:#{@value} must not exceed #{KEY}:#{@parameter_definition[KEY]} characters"
        end

      end
    end
  end
end
