module StackMaster
  class ParameterResolver
    ResolverNotFound = Class.new(StandardError)
    InvalidParameter = Class.new(StandardError)

    def self.resolve(config, stack_definition, parameters)
      new(config, stack_definition, parameters).resolve
    end

    def initialize(config, stack_definition, parameters)
      @config = config
      @stack_definition = stack_definition
      @parameters = parameters
      @resolvers = {}
    end

    def resolve
      @parameters.reduce({}) do |parameters, (key, value)|
        parameters[key] = resolve_parameter_value(value)
        parameters
      end
    end

    private

    def resolve_parameter_value(parameter_value)
      return parameter_value if String === parameter_value || parameter_value.nil?
      raise InvalidParameter, parameter_value unless Hash === parameter_value
      raise InvalidParameter, parameter_value unless parameter_value.keys.size == 1
      resolver_class_name = parameter_value.keys.first.to_s.camelize
      value = parameter_value.values.first
      resolver_class(resolver_class_name).new(@config, @stack_definition, value).resolve
    end

    def resolver_class(class_name)
      @resolvers.fetch(class_name) do
        begin
          Kernel.const_get("StackMaster::ParameterResolvers::#{class_name}")
        rescue NameError
          raise ResolverNotFound, class_name
        end
      end
    end
  end
end
