require 'deep_merge/rails_compat'
require 'active_support/core_ext/object/deep_dup'

module StackMaster
  class Config
    class StackDefinitions
      attr_reader :stacks

      def initialize(base_dir, stack_defaults, region_defaults)
        @base_dir = base_dir
        @stack_defaults = stack_defaults
        @region_defaults = region_defaults
        @stacks = []
      end

      def load(stacks)
        stacks.each do |region, stacks_for_region|
          region = Utils.underscore_to_hyphen(region)
          stacks_for_region.each do |stack_name, attributes|
            stack_name = Utils.underscore_to_hyphen(stack_name)
            stack_attributes = stack_defaults(region).deeper_merge(attributes).merge(
              'region' => region,
              'stack_name' => stack_name,
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

      def stack_defaults(region)
        region_defaults = @region_defaults.fetch(region, {}).deep_dup
        @stack_defaults.deep_dup.deeper_merge(region_defaults)
      end
    end
  end
end
