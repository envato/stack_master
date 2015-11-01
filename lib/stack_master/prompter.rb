module StackMaster
  module Prompter
    def ask?(question)
      StackMaster.stdout.print question
      answer = if ENV['STUB_AWS']
        ENV['ANSWER']
      else
        STDIN.getch.chomp
      end
      StackMaster.stdout.puts
      answer == 'y'
    end
  end
end
