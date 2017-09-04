require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class AllowedValuesValidator < ValueValidator

        KEY = :allowed_values

        def initialize(name, parameter_definition, value)
          @name = name
          @parameter_definition = parameter_definition
          @value = value
        end

        private

        def check_is_valid
          return true unless @parameter_definition.key?(KEY)
          value_is_allowed?
        end

        def value_is_allowed?
          @parameter_definition[KEY].include?(@value)
        end

        def create_error
          "#{@name}:#{@value} is not in #{KEY}:#{@parameter_definition[KEY].join(',')}"
        end

      end
    end
  end
end
