module StackMaster
  module Command
    def self.included(base)
      base.extend ClassMethods
      base.prepend Perform
    end

    module ClassMethods
      def perform(*args)
        new(*args).tap do |command|
          command.perform
        end
      end

      def command_name
        name.split('::').last.underscore
      end
    end

    module Perform
      def perform
        catch(:halt) do
          super
        end
      rescue Aws::CloudFormation::Errors::ServiceError, TemplateCompiler::TemplateCompilationFailed => e
        failed error_message(e)
      end
    end

    def success?
      @failed != true
    end

    private

    def error_message(e)
      msg = "#{e.class} #{e.message}"
      msg = "\n Caused by: #{e.cause.class} #{e.cause.message}" if e.cause
      msg
    end

    def failed(message = nil)
      StackMaster.stderr.puts(message) if message
      @failed = true
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
