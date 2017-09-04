module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MinLengthValidator

        KEY = :min_length

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
           create_error if value_is_less_than_min_length?
        end

        private

        def value_is_less_than_min_length?
          @value.length < @parameter_definition[KEY].to_i
        end

        def create_error
          [KEY, "Value must be at least #{@parameter_definition[KEY]} characters"]
        end

      end
    end
  end
end
