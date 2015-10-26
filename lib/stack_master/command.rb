module StackMaster
  module Command
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def perform(*args)
        new(*args).perform
      end
    end
  end
end
