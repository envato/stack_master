module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class EmptyValidator

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
          create_error if value_is_empty?
        end

        private

        def value_is_empty?
          @value.to_s.strip.empty?
        end

        def create_error
          [:undefined, 'Value cannot be blank']
        end

      end
    end
  end
end
