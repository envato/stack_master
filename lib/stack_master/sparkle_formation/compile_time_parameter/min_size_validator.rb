require_relative 'validator'

module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MinSizeValidator < Validator

        KEY = :min_size

        def initialize(name, parameter_definition, value)
          @name = name
          @parameter_definition = parameter_definition
          @value = value
        end

        private

        def check_is_valid
          return true unless @parameter_definition.key?(KEY)
          !value_is_less_than_min_size?
        end

        def value_is_less_than_min_size?
          @value.to_i < @parameter_definition[KEY].to_i
        end

        def create_error
          "#{@name}:#{@value} must not be less than #{KEY}:#{@parameter_definition[KEY]}"
        end

      end
    end
  end
end
