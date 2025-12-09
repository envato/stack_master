module StackMaster
  module ParameterResolvers
    class OnePassword < Resolver
      OnePasswordNotFound = Class.new(StandardError)
      OnePasswordNotAbleToAuthenticate = Class.new(StandardError)
      OnePasswordBinaryNotFound = Class.new(StandardError)
      OnePasswordInvalidResponse = Class.new(StandardError)
      OnePasswordInvalidVersion = Class.new(StandardError)

      array_resolver

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(params={})
        raise OnePasswordNotAbleToAuthenticate, "1password requires the `OP_SESSION_<name>` to be set, (remember to sign in?)" if ENV.keys.grep(/OP_SESSION_\w+$/).empty?    
        get_items(params)
      end

      private

      def validate_op_installed?
        %x(op --version)
      rescue Errno::ENOENT => exception
        raise OnePasswordBinaryNotFound, "The op cli needs to be installed and in the PATH, #{exception}"
      end

      def validate_response?(item)
        item.match(/\[LOG\].+(?<error>\(.+)$/)  do |i|
          raise OnePasswordNotFound, "Failed to return item from 1password, #{i['error']}"
        end
        JSON.parse(item)
      rescue JSON::ParserError => exception
        raise OnePasswordInvalidResponse, "Failed to parse JSON returned, #{item}: #{exception}"
      end

      def is_login_item?(data)
        data.details.password.nil?
      end

      def password_item(data)
        data.details.password 
      end

      def login_item(data)
        data.details.fields[1].value
      end

      def op_get_item(item, vault)
        validate_op_installed?
        
        get_item(item, vault, get_version)
        
      end

      def create_struct(title, vault)
        JSON.parse(op_get_item(title, vault), object_class: OpenStruct)
      end

      def get_password(title, vault)
        # There are two types of password that can be returned.
        # One is attached to a Login item in 1Password
        # the other is to a Password item.
        if is_login_item?(create_struct(title, vault))
          login_item(create_struct(title, vault))
        else
          password_item(create_struct(title, vault))
        end
      end

      def get_secure_note(title, vault)
        version = get_version
        if version.start_with?("1")
          return create_struct(title, vault).details.notesPlain
        end
        if version.start_with?("2")
          create_struct(title, vault).fields.first.value
        end
      end

      def get_items(params)
        case params['type']
        when 'password'
          return get_password(params['title'], params['vault'])
        when 'secureNote'
          return get_secure_note(params['title'], params['vault'])
        end
      end

      def get_version
        %x(op --version).strip
      end

      def get_item(item, vault, version)
        case version
        when version.start_with?("1")
          %x(op get item --vault='#{vault}' '#{item}' 2>&1)
        when version.start_with?("2")
          %x(op item get --vault='#{vault}' '#{item}' --format json 2>&1)
        else
          raise OnePasswordInvalidVersion, "Unsupported version of 1Password: #{version}"
        end
      end
    end
  end
end
