require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class DefinitionValidator

        def initialize(name, definition)
          @name = name
          @type = definition[:type]
          @valid_types = [:string, :number]
        end


        def validate
            raise ArgumentError.new "Unknown compile time parameter type: #{create_error}" unless is_valid
        end

        private

        def is_valid
          @valid_types.include? @type
        end

        def create_error
          "#{@name}:#{@type} valid types are #{@valid_types}"
        end

      end
    end
  end
end