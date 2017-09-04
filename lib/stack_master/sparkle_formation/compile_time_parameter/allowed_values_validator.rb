module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class AllowedValuesValidator

        KEY = :allowed_values

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
