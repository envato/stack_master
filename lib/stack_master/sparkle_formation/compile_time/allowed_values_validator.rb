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
          invalid_parameters.empty?
        end

        def invalid_parameters
          parameter_list = build_parameters(@definition, @parameter)
          parameter_list.reject {|parameter| @definition[KEY].any? {|allowed_value| allowed_value.to_s == parameter.to_s}}
        end

        def create_error
          "#{@name}:#{invalid_parameters} is not in #{KEY}:#{@definition[KEY]}"
        end

      end
    end
  end
end
