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
        begin
          parameters[key] = resolve_parameter_value(key, value)
        rescue InvalidParameter
          raise InvalidParameter, "Unable to resolve parameter #{key.inspect} value causing error: #{$!.message}"
        end
        parameters
      end
    end

    private

    def require_parameter_resolver(file_name)
      require "stack_master/parameter_resolvers/#{file_name}"
    rescue LoadError
      if file_name == file_name.singularize
        raise ResolverNotFound.new(file_name)
      else
        require_parameter_resolver(file_name.singularize)
      end
    end

    def load_parameter_resolver(class_name)
      # Check if the class name already exists
      resolver_class_const(class_name)
    rescue NameError
      # If it doesn't, try to load it
      require_parameter_resolver(class_name.underscore)
    end

    def resolve_parameter_value(key, parameter_value)
      return parameter_value.to_s if Numeric === parameter_value || parameter_value == true || parameter_value == false
      return parameter_value.join(',') if Array === parameter_value
      return parameter_value unless Hash === parameter_value
      validate_parameter_value!(key, parameter_value)

      resolver_name = parameter_value.keys.first.to_s
      load_parameter_resolver(resolver_name)

      value = parameter_value.values.first
      resolver_class_name = resolver_name.camelize
      call_resolver(resolver_class_name, value)
    rescue Aws::CloudFormation::Errors::ValidationError
      raise InvalidParameter, $!.message
    end

    def call_resolver(class_name, value)
      resolver_class(class_name).resolve(value)
    end

    def resolver_class_name(class_name)
      "StackMaster::ParameterResolvers::#{class_name.camelize}"
    end

    def resolver_class_const(class_name)
      Kernel.const_get(resolver_class_name(class_name))
    end

    def resolver_class(class_name)
      @resolvers.fetch(class_name) do
        begin
          @resolvers[class_name] = resolver_class_const(class_name).new(@config, @stack_definition)
        rescue NameError
          raise ResolverNotFound, "Could not find parameter resolver called #{class_name}, please double check your configuration"
        end
      end
    end

    def validate_parameter_value!(key, parameter_value)
      if parameter_value.keys.size != 1
        raise InvalidParameter, "#{key} hash contained more than one key: #{parameter_value.inspect}"
      end
    end
  end
end
