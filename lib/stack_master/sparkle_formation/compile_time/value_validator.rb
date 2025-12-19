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
          raise NotImplementedError
        end

        def create_error
          raise NotImplementedError
        end

        def build_values(definition, parameter)
          parameter_or_default = parameter.nil? ? definition[:default] : parameter
          convert_to_array(definition, parameter_or_default)
        end

        private

        def convert_to_array(definition, parameter)
          return parameter.split(',').map(&:strip) if definition[:multiple] && parameter.is_a?(String)

          parameter.is_a?(Array) ? parameter : [parameter]
        end
      end
    end
  end
end
