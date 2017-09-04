module StackMaster
  module SparkleFormation
    module CompileTimeParameter
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

      end
    end
  end
end