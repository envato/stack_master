module StackMaster
  class Config
    class StackDefinitions
      attr_reader :stacks

      def initialize(base_dir)
        @base_dir = base_dir
        @stacks = []
      end

      def load(stacks)
        stacks.each do |region, stacks_for_region|
          stacks_for_region.each do |stack_name, attributes|
            stack_attributes = attributes.merge(
              'region' => underscore_to_hyphen(region),
              'stack_name' => underscore_to_hyphen(stack_name),
              'base_dir' => @base_dir)
            @stacks << StackDefinition.new(stack_attributes)
          end
        end
      end

      def find_stack(region, stack_name)
        @stacks.find do |s|
          (s.region == region || s.region == region.gsub('_', '-')) &&
            (s.stack_name == stack_name || s.stack_name == stack_name.gsub('_', '-'))
        end
      end

      private

      def underscore_to_hyphen(string)
        string.gsub('_', '-')
      end
    end
  end
end
