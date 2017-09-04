module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MinSizeValidator

        KEY = :min_size

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
          create_error if value_is_less_than_min_size?
        end

        private

        def value_is_less_than_min_size?
          @value.to_i < @parameter_definition[KEY].to_i
        end

        def create_error
          [KEY, "Value must not be less than #{@parameter_definition[KEY]}"]
        end

      end
    end
  end
end
