module StackMaster
  module Command
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def perform(*args)
        new(*args).tap { |command| command.perform }
      end
    end

    def failed
      @failed = true
    end

    def success?
      @failed != true
    end
  end
end
