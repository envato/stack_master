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
          invalid_parameters.empty?
        end

        def create_error
          "#{@name}:#{invalid_parameters} does not match #{KEY}:#{@definition[KEY]}"
        end

        def invalid_parameters
          parameter = @parameter.nil? ? @definition[:default] : @parameter
          parameter_list = convert_to_array(parameter)
          parameter_list.reject do |parameter|
            parameter.nil? ? false : parameter.to_s.match(%r{#{@definition[KEY]}})
          end
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
