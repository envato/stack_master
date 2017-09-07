require_relative 'parameter_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class MaxSizeValidator < ValueValidator

        KEY = :max_size

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
          parameter = @parameter.nil? ? @definition[:default] : @parameter
          parameter_list = convert_to_array(parameter)
          parameter_list.select do |parameter|
            parameter.nil? ? true : parameter.to_i > @definition[KEY].to_i
          end
        end

        def create_error
          "#{@name}:#{invalid_values} must not be greater than #{KEY}:#{@definition[KEY]}"
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
