module StackMaster
  module SparkleFormation
    module CompileTime
      class ParameterBuilder

        def initialize(definition, parameter)
          @definition = definition
          @parameter = parameter
        end

        def build
          parameter_or_default
          convert_strings_to_array
          convert_strings_to_numbers
          @compile_parameter
        end

        private

        def parameter_or_default
          @compile_parameter = @parameter.nil? ? @definition[:default] : @parameter
        end

        def convert_strings_to_array
          if @definition[:multiple] && @compile_parameter.is_a?(String)
            @compile_parameter = @compile_parameter.split(',').map(&:strip)
          end
        end

        def convert_strings_to_numbers
          if @definition[:type] == :number
            @compile_parameter = @compile_parameter.to_f if @compile_parameter.is_a?(String)
            if @compile_parameter.is_a?(Array)
              @compile_parameter = @compile_parameter.map do |item|
                item.is_a?(String) ? item.strip.to_f : item
              end
            end
          end
        end

      end
    end
  end
end
