module StackMaster
  module SparkleFormation
    module CompileTime
      class ParameterBuilder

        def initialize(definition, parameter)
          @definition = definition
          @parameter = parameter
        end

        def build
          compile_parameter = parameter_or_default(@definition, @parameter)
          compile_parameter = convert_strings_to_array(compile_parameter) if @definition[:multiple]
          compile_parameter = convert_strings_to_integers(compile_parameter) if @definition[:type] == :number
          compile_parameter
        end

        private

        def parameter_or_default(definition, parameter)
          parameter.nil? ? definition[:default] : parameter
        end

        def convert_strings_to_array(compile_parameter)
          compile_parameter.is_a?(String) ? compile_parameter.split(',').map(&:strip) : compile_parameter
        end

        def convert_strings_to_integers(compile_parameter)
          return compile_parameter.map {|item| item.strip.to_i} if compile_parameter.is_a?(Array)
          return compile_parameter.to_i if compile_parameter.is_a?(String)
          compile_parameter
        end

      end
    end
  end
end
