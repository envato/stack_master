require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class MinSizeValidator < ValueValidator

        KEY = :min_size

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          return true unless @definition[:type] == :number
          return true unless @definition.key?(KEY)
          invalid_values.empty?
        end

        def invalid_values
          values = build_values(@definition, @parameter)
          values.select {|value| value.to_f < @definition[KEY].to_f}
        end

        def create_error
          "#{@name}:#{invalid_values} must not be lesser than #{KEY}:#{@definition[KEY]}"
        end

      end
    end
  end
end
