require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class AllowedPatternValidator < ValueValidator

        KEY = :allowed_pattern

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          return true unless @definition.key?(KEY)
          invalid_values.empty?
        end

        def invalid_values
          values = build_values(@definition, @parameter)
          values.reject { |value| value.to_s.match(%r{#{@definition[KEY]}}) }
        end

        def create_error
          "#{@name}:#{invalid_values} does not match #{KEY}:#{@definition[KEY]}"
        end

      end
    end
  end
end
