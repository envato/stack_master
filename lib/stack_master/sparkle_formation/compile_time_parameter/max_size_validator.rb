module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MaxSizeValidator

        KEY = :max_size

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
          return unless @parameter_definition.key?(KEY)
          create_error if value_is_greater_than_max_size?
        end

        private

        def value_is_greater_than_max_size?
          @value.to_i > @parameter_definition[KEY].to_i
        end

        def create_error
          [KEY, "Value must not be greater than #{@parameter_definition[KEY]}"]
        end

      end
    end
  end
end
