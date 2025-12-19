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
      @parameters.each_with_object({}) do |(key, value), parameters|
        begin
          parameters[key] = resolve_parameter_value(key, value)
        rescue InvalidParameter
          raise InvalidParameter, "Unable to resolve parameter #{key.inspect} value causing error: #{$!.message}"
        end
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
      if parameter_value.is_a?(Numeric) || parameter_value == true || parameter_value == false
        return parameter_value.to_s
      end
      return resolve_array_parameter_values(key, parameter_value).join(',') if parameter_value.is_a?(Array)
      return parameter_value unless parameter_value.is_a?(Hash)

      resolve_parameter_resolver_hash(key, parameter_value)
    rescue Aws::CloudFormation::Errors::ValidationError
      raise InvalidParameter, $!.message
    end

    def resolve_parameter_resolver_hash(key, parameter_value)
      # strip out account and role
      resolver_hash = parameter_value.except('account', 'role')
      account, role = parameter_value.values_at('account', 'role')

      validate_parameter_value!(key, resolver_hash)

      resolver_name = resolver_hash.keys.first.to_s
      load_parameter_resolver(resolver_name)

      value = resolver_hash.values.first
      resolver_class_name = resolver_name.camelize

      assume_role_if_present(account, role, key) do
        call_resolver(resolver_class_name, value)
      end
    end

    def assume_role_if_present(account, role, key, &block)
      return yield if account.nil? && role.nil?
      if account.nil? || role.nil?
        raise InvalidParameter, "Both 'account' and 'role' are required to assume role for parameter '#{key}'"
      end

      role_assumer.assume_role(account, role, &block)
    end

    def resolve_array_parameter_values(key, parameter_values)
      parameter_values.reduce([]) do |values, parameter_value|
        values << resolve_parameter_value(key, parameter_value)
      end
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
          raise ResolverNotFound,
                "Could not find parameter resolver called #{class_name}, please double check your configuration"
        end
      end
    end

    def validate_parameter_value!(key, parameter_value)
      if parameter_value.keys.size != 1
        raise InvalidParameter, "#{key} hash contained more than one key: #{parameter_value.inspect}"
      end
    end

    def role_assumer
      @role_assumer ||= RoleAssumer.new
    end
  end
end
