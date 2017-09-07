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
          parameter_is_allowed?
        end

        def parameter_is_allowed?
          invalid_parameters.empty?
        end

        def create_error
          "#{@name}:#{invalid_parameters} is not in #{KEY}:#{@definition[KEY]}"
        end

        def invalid_parameters
          parameter_or_default = @parameter.nil? ? @definition[:default] : @parameter
          parameter_list = convert_to_array(parameter_or_default)
          parameter_list.reject {|parameter| @definition[KEY].any? {|allowed_value| allowed_value.to_s == parameter.to_s}}
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
