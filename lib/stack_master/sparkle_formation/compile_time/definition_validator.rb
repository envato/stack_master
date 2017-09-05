require_relative 'validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class DefinitionValidator < Validator

        def initialize(name, definition)
          @name = name
          @type = definition[:type]
          @valid_types = [:string, :number]
        end

        def check_is_valid
          @valid_types.include? @type
        end

        def create_error
          "#{@name}:#{@type} valid types are #{@valid_types.pretty_inspect}"
        end

      end
    end
  end
end