module StackMaster
  module Config
    class StackDefinitions
      def initialize
        @stacks = []
      end

      def load(stacks)
        stacks.each do |region, stacks_for_region|
          stacks_for_region.each do |stack_name, attributes|
            @stacks << StackDefinition.new(attributes.merge('region' => region, 'stack_name' => stack_name))
          end
        end
      end

      def find_stack(region, stack_name)
        @stacks.find do |s|
          s.region == region && s.stack_name == stack_name
        end
      end
    end
  end
end
