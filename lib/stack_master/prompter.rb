module StackMaster
  module Prompter
    def ask?(question)
      StackMaster.stdout.print question
      answer = if ENV['STUB_AWS']
        ENV['ANSWER']
      else
        STDIN.gets.chomp
      end
      answer =~ /y(es)?/i
    end
  end
end
