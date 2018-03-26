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

      def op_get_item(item, vault)
        begin
          item = %x(op get item --vault='#{vault}' '#{item}' 2>&1)
          return item if JSON.parse(item)
        rescue Errno::ENOENT
          raise RuntimeError, "The op cli needs to be installed in the PATH"
        rescue => exception
          raise RuntimeError, "Failed to return item from 1password, #{item}"
        end
      end

      def get_password(title, vault)
        JSON.parse(op_get_item(title, vault))['details']['fields'].select { |k,v| k.key('password') }[0].values_at('value').first
      end
      
      def get_secure_note(title, vault)
        JSON.parse(op_get_item(title, vault))['details'].values_at('notesPlain').first
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
