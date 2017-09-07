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
          parameter_or_default = @parameter.nil? ? @definition[:default] : @parameter
          parameter_list = convert_to_array(parameter_or_default)
          parameter_list.select {|parameter| parameter.to_f < @definition[KEY].to_f}
        end

        def create_error
          "#{@name}:#{invalid_values} must not be lesser than #{KEY}:#{@definition[KEY]}"
        end

        def convert_to_array(parameter)
          if @definition[:multiple] && parameter.is_a?(String)
            return parameter.split(',').map(&:strip)
          end
          parameter.is_a?(Array) ? parameter : [parameter]
        end

      end
    end
  end
end
