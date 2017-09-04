module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class EmptyValidator

        attr_reader :is_valid, :error

        def initialize(name, _definition, value)
          @name = name
          @value = value
        end

        def validate
          @is_valid = check_is_valid
          @error = create_error unless @is_valid
        end

        private

        def check_is_valid
          !value_is_empty?
        end

        def value_is_empty?
          @value.to_s.strip.empty?
        end

        def create_error
          "#{@name} cannot be blank"
        end

      end
    end
  end
end
