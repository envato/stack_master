module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class AllowedValuesValidator

        KEY = :allowed_values

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
          return unless @parameter_definition.key?(KEY)
          create_error unless value_is_allowed?
        end

        private

        def value_is_allowed?
          @parameter_definition[KEY].include?(@value)
        end

        def create_error
          [KEY, "Not an allowed value: #{@parameter_definition[KEY].join(', ')}"]
        end

      end
    end
  end
end
