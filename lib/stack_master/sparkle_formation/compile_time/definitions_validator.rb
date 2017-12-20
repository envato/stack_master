require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class DefinitionsValidator

        VALID_TYPES = [:string, :number]
        def initialize(definitions)
          @definitions = definitions
        end

        def validate
          @definitions.each do|name, definition|
            type = definition[:type]
            raise ArgumentError.new "Unknown compile time parameter type: #{create_error(name, type)}" unless is_valid(type)
          end
        end

        private

        def is_valid(type)
          VALID_TYPES.include? type
        end

        def create_error(name, type)
          "#{name}:#{type} valid types are #{VALID_TYPES}"
        end

      end
    end
  end
end