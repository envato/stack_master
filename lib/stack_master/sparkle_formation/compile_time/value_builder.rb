module StackMaster
  module SparkleFormation
    module CompileTime
      class ValueBuilder

        def initialize(definition, parameter)
          @definition = definition
          @parameter = parameter
        end

        def build
          parameter_or_default
          convert_strings_to_array
          convert_strings_to_numbers
          @value
        end

        private

        def parameter_or_default
          @value = @parameter.nil? ? @definition[:default] : @parameter
        end

        def convert_strings_to_array
          if @definition[:multiple] && @value.is_a?(String)
            @value = @value.split(',').map(&:strip)
          end
        end

        def convert_strings_to_numbers
          if @definition[:type] == :number
            @value = @value.to_f if @value.is_a?(String)
            @value = @value.map { |item| item.is_a?(String) ? item.to_f : item } if @value.is_a?(Array)
          end
        end

      end
    end
  end
end
