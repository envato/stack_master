module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MaxLengthValidator

        KEY = :max_length

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
          return unless @parameter_definition.key?(KEY)
          create_error if value_is_greater_than_max_length?
        end

        private

        def value_is_greater_than_max_length?
          @value.length > @parameter_definition[KEY].to_i
        end

        def create_error
          [KEY, "Value must not exceed #{@parameter_definition[KEY]} characters"]
        end

      end
    end
  end
end
