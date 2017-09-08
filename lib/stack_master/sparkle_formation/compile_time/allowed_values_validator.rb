require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class AllowedValuesValidator < ValueValidator

        KEY = :allowed_values

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
          values.reject do |value|
            @definition[KEY].any? { |allowed_value| allowed_value.to_s == value.to_s}
          end
        end

        def create_error
          "#{@name}:#{invalid_values} is not in #{KEY}:#{@definition[KEY]}"
        end

      end
    end
  end
end
