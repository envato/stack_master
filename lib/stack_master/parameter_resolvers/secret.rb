require 'os'

module StackMaster
  module ParameterResolvers
    class Secret < Resolver
      SecretNotFound = Class.new(StandardError)
      PlatformNotSupported = Class.new(StandardError)

      unless OS.windows?
        require 'dotgpg'
        array_resolver  
      end

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(value)
        raise PlatformNotSupported, "The GPG Secret Parameter Resolver does not support Windows" if OS.windows?
        secret_key = value
        raise ArgumentError, "No secret_file defined for stack definition #{@stack_definition.stack_name} in #{@stack_definition.region}" unless !@stack_definition.secret_file.nil?
        raise ArgumentError, "Could not find secret file at #{secret_file_path}" unless File.exist?(secret_file_path)
        StackMaster.stderr.puts """[DEPRECATION WARNING] The GPG Parameter Resolver is being deprecated in favour of the Parameter Store and 1Password resolvers.
Support for GPG encrypted secrets will be removed in StackMaster 2.0"""
        secrets_hash.fetch(secret_key) do
          raise SecretNotFound, "Unable to find key #{secret_key} in file #{secret_file_path}"
        end
      end

      private

      def secrets_hash
        @secrets_hash ||= YAML.load(decrypt_with_dotgpg)
      end

      def decrypt_with_dotgpg
        Dotgpg.interactive = true
        dir = Dotgpg::Dir.closest(secret_file_path)
        stream = StringIO.new
        dir.decrypt(secret_path_relative_to_base, stream)
        stream.string
      end

      def secret_path_relative_to_base
        @secret_path_relative_to_base ||= File.join('secrets', @stack_definition.secret_file)
      end

      def secret_file_path
        @secret_file_path ||= File.join(@config.base_dir, secret_path_relative_to_base)
      end
    end
  end
end
