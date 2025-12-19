require_relative 'value_validator'

module StackMaster
  module SparkleFormation
    module CompileTime
      class DefinitionsValidator
        VALID_TYPES = %i[string number]
        def initialize(definitions)
          @definitions = definitions
        end

        def validate
          @definitions.each do |name, definition|
            type = definition[:type]
            unless is_valid(type)
              raise ArgumentError.new "Unknown compile time parameter type: #{create_error(name, type)}"
            end
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
