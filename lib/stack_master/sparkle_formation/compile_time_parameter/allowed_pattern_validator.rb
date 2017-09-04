module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class AllowedPatternValidator

        KEY = :allowed_pattern

        def initialize(parameter_definition, value)
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
           create_error unless value_matches_pattern?
        end

        private

        def value_matches_pattern?
          @value.match(%r{#{@parameter_definition[KEY]}})
        end

        def create_error
          [KEY, "Not a valid pattern. Must match: #{@parameter_definition[KEY]}"]
        end

      end
    end
  end
end
