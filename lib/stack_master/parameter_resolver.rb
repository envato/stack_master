module StackMaster
  class ParameterResolver
    ResolverNotFound = Class.new(StandardError)
    InvalidParameter = Class.new(StandardError)

    def self.resolve(region, parameters)
      new(region, parameters).resolve
    end

    def initialize(region, parameters)
      @region = region
      @parameters = parameters
    end

    def resolve
      @parameters.reduce({}) do |parameters, (key, value)|
        parameters[key] = resolve_value(value)
        parameters
      end
    end

    private

    def resolve_value(value)
      return value if String === value || value.nil?
      raise InvalidParameter, value unless Hash === value
      raise InvalidParameter, value unless value.keys.size == 1
      resolver_class_name = value.keys.first.to_s.camelize
      value = value.values.first
      resolver_class = begin
        Kernel.const_get("StackMaster::ParameterResolvers::#{resolver_class_name}")
      rescue NameError
        raise ResolverNotFound, resolver_class_name
      end
      resolver_class.new(@region, value).resolve
    end
  end
end
