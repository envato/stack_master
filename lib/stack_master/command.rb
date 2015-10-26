module StackMaster
  module Command
    def self.perform(*args)
      new(*args).perform
    end
  end
end
