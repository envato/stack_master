module StackMaster
  module Prompter
    def ask?(question)
      StackMaster.stdout.print question
      answer = if StackMaster.interactive?
        STDIN.getch.chomp
      else
        ENV.fetch('ANSWER') { 'y' }
      end
      StackMaster.stdout.puts
      answer == 'y'
    end
  end
end
