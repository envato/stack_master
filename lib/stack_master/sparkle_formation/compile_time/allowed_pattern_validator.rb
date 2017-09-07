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

        def invalid_parameters
          parameter_list = build_parameters(@definition, @parameter)
          parameter_list.reject {|parameter| parameter.to_s.match(%r{#{@definition[KEY]}})}
        end

        def create_error
          "#{@name}:#{invalid_parameters} does not match #{KEY}:#{@definition[KEY]}"
        end

      end
    end
  end
end
