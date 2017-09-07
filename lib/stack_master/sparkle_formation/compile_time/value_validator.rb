module StackMaster
  module SparkleFormation
    module CompileTime
      class ValueValidator

        attr_reader :is_valid, :error

        def validate
          @is_valid = check_is_valid
          @error = create_error unless @is_valid
        end

        protected

        def check_is_valid
          true
        end

        def create_error

        end

        def build_parameters(definition, parameter)
          parameter_or_default = parameter.nil? ? definition[:default] : parameter
          convert_to_array(definition, parameter_or_default)
        end

        private

        def convert_to_array(definition, parameter)
          if definition[:multiple] && parameter.is_a?(String)
            return parameter.split(',').map(&:strip)
          end
          parameter.is_a?(Array) ? parameter : [parameter]
        end

      end
    end
  end
end