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

        def has_invalid_parameters?
          parameter_list = build_parameters(@definition, @parameter)
          parameter_list.include?(nil) || parameter_list.include?('')
        end

        def create_error
          "#{@name} cannot contain empty parameters:#{@parameter.inspect}"
        end

      end
    end
  end
end