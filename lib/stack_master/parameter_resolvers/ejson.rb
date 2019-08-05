require 'ejson_wrapper'

module StackMaster
  module ParameterResolvers
    class Ejson < Resolver
      SecretNotFound = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(secret_key)
        validate_ejson_file_specified
        secrets = decrypt_ejson_file
        secrets.fetch(secret_key.to_sym) do
          raise SecretNotFound, "Unable to find key #{secret_key} in file #{ejson_file}"
        end
      end

      private

      def validate_ejson_file_specified
        if @stack_definition.ejson_file.nil?
          raise ArgumentError, "No ejson_file defined for stack definition #{@stack_definition.stack_name} in #{@stack_definition.region}"
        end
      end

      def decrypt_ejson_file
        @decrypt_ejson_file ||= EJSONWrapper.decrypt(ejson_file_path,
                                                     use_kms: true,
                                                     region: ejson_file_region)
      end

      def ejson_file_region
        @stack_definition.ejson_file_region || StackMaster.cloud_formation_driver.region
      end

      def ejson_file_path
        @ejson_file_path ||= File.join(@config.base_dir, secret_path_relative_to_base)
      end

      def secret_path_relative_to_base
        @secret_path_relative_to_base ||= File.join('secrets', @stack_definition.ejson_file)
      end
    end
  end
end
