require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class EmptyValidator < ValueValidator

        def initialize(name, definition, parameter)
          @name = name
          @definition = definition
          @parameter = parameter
        end

        private

        def check_is_valid
          !has_invalid_parameters?
        end

        def create_error
          "#{@name} cannot contain empty parameters:#{@parameter.inspect}"
        end

        def has_invalid_parameters?
          parameter = @parameter.nil? ? @definition[:default] : @parameter
          parameter_list = convert_to_array(parameter)
          parameter_list.include?(nil) || parameter_list.include?('')
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
