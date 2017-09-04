module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class AllowedPatternValidator

        KEY = :allowed_pattern

        attr_reader :is_valid, :error

        def initialize(name, parameter_definition, value)
          @name = name
          @parameter_definition = parameter_definition
          @value = value
        end

        def validate
          @is_valid = check_is_valid
          @error = create_error unless @is_valid
        end

        private

        def check_is_valid
          return true unless @parameter_definition.key?(KEY)
          value_matches_pattern?
        end

        def value_matches_pattern?
          @value.match(%r{#{@parameter_definition[KEY]}})
        end

        def create_error
          "#{@name}:#{@value} does not match #{KEY}:#{@parameter_definition[KEY]}"
        end

      end
    end
  end
end
