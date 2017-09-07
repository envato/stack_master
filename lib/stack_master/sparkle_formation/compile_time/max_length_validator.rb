require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class MaxLengthValidator < ValueValidator

        KEY = :max_length

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          return true unless @definition[:type] == :string
          return true unless @definition.key?(KEY)
          invalid_values.empty?
        end

        def invalid_values
          parameter_list = build_parameters(@definition, @parameter)
          parameter_list.select { |parameter| parameter.length > @definition[KEY].to_i }
        end

        def create_error
          "#{@name}:#{invalid_values} must not exceed #{KEY}:#{@definition[KEY]} characters"
        end

      end
    end
  end
end
