module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class MinLengthValidator

        KEY = :min_length

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
          !value_is_less_than_min_length?
        end

        def value_is_less_than_min_length?
          @value.length < @parameter_definition[KEY].to_i
        end

        def create_error
          "#{@name}:#{@value} must be at least #{KEY}:#{@parameter_definition[KEY]} characters"
        end

      end
    end
  end
end
