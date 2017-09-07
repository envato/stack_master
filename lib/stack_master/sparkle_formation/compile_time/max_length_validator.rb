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
          return true unless @definition.key?(KEY)
          invalid_values.empty?
        end

        def invalid_values
          parameter = @parameter.nil? ? @definition[:default] : @parameter
          parameter_list = convert_to_array(parameter)
          parameter_list.select do |parameter|
            parameter.nil? ? true : parameter.length > @definition[KEY].to_i
          end
        end

        def create_error
          "#{@name}:#{invalid_values} must not exceed #{KEY}:#{@definition[KEY]} characters"
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
