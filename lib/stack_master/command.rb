module StackMaster
  module Command
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def perform(*args)
        new(*args).tap do |command|
          catch(:halt) do
            command.perform
          end
        end
      end

      def command_name
        name.split('::').last.underscore
      end
    end

    def failed(message = nil)
      @failed = true
      StackMaster.stderr.puts(message) if message
    end

    def success?
      @failed != true
    end

    def failed!(message = nil)
      failed(message)
      halt!
    end

    def halt!(message = nil)
      StackMaster.stdout.puts(message) if message
      throw :halt
    end
  end
end
