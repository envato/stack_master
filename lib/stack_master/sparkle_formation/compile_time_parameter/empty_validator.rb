module StackMaster
  module SparkleFormation
    module CompileTimeParameter
      class EmptyValidator

        def initialize(name, _definition, value)
          @name = name
          @value = value
        end

        def is_valid?
          !value_is_empty?
        end

        def error
          create_error
        end

        private

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
