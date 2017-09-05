require_relative 'validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class EmptyValidator < Validator

        def initialize(name, definition, value)
          @name = name
          @definition = definition
          @value = value
        end

        private

        def check_is_valid
          has_value? || has_default?
        end

        def has_value?
          !@value.to_s.strip.empty?
        end

        def has_default?
          !@definition[:default].nil? && !@definition[:default].to_s.strip.empty?
        end

        def create_error
          "#{@name} cannot be blank"
        end

      end
    end
  end
end
