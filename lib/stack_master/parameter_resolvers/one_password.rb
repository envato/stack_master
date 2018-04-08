module StackMaster
  module ParameterResolvers
    class OnePassword < Resolver
      OnePasswordNotFound = Class.new(StandardError)

      array_resolver

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(params={})
        raise RuntimeError, "1password requires the `OP_SESSION_<name>` to be set" if ENV.keys.grep(/OP_SESSION_\w+$/).empty?    
        get_items(params)
      end

      private

      def validate_op_installed?
        %x(op --version)
        rescue Errno::ENOENT => exception
          raise RuntimeError, "The op cli needs to be installed and in the PATH, #{exception}"
      end

      def parseable_json?(item)
        JSON.parse(item)
        rescue TypeError => exception
          raise "item returned is not valid JSON: #{item}"
        rescue JSON::ParserError => exception
          raise "Failed to parse JSON returned, #{item}"
      end

      def op_get_item(item, vault)
        validate_op_installed?
        begin
          item = %x(op get item --vault='#{vault}' '#{item}' 2>&1)
          item if parseable_json?(item)
        rescue => exception
          raise RuntimeError, "Failed to return item from 1password, #{item}"
        end
      end

      def create_struct(title, vault)
        JSON.parse(op_get_item(title, vault), object_class: OpenStruct)
      end

      def get_password(title, vault)
        create_struct(title, vault).details.fields[1].value
      end
      
      def get_secure_note(title, vault)
        create_struct(title, vault).details.notesPlain
      end

      def get_items(params)
        case params['type']
        when 'password'
          return get_password(params['title'], params['vault'])
        when 'secureNote'
          return get_secure_note(params['title'], params['vault'])
        end
      end
    end
  end
end
