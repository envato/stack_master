module StackMaster
  module ParameterResolvers
    class ResolverArray
      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(values)
        value_list = Array(values).map do |value|
          resolver_class.new(@config, @stack_definition).resolve(value)
        end
      end

      def resolver_class
        fail "Method resolver_class not implemented on #{self.class}"
      end
    end

    class Resolver
      def self.array_resolver(options = {})
        resolver_class ||= Object.const_get(self.name)
        array_resolver_class_name = options[:class_name] || resolver_class.to_s.demodulize.pluralize

        puts "Creating resolver for #{resolver_class}"
        klass = Class.new(ResolverArray) do
          define_method('resolver_class') do
            resolver_class
          end
        end
        StackMaster::ParameterResolvers.const_set("#{array_resolver_class_name}", klass)
      end
    end
  end
end

