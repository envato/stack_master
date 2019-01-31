require 'io/console'

module StackMaster
  module Prompter
    def ask?(question)
      StackMaster.stdout.print question
      answer = if StackMaster.interactive?
        if StackMaster.stdin.tty? && StackMaster.stdout.tty?
          StackMaster.stdin.getch.chomp
        else
          StackMaster.stdout.puts
          StackMaster.stdout.puts "STDOUT or STDIN was not a TTY. Defaulting to no. To force yes use -y"
          'n'
        end
      else
        print StackMaster.non_interactive_answer
        StackMaster.non_interactive_answer
      end
      StackMaster.stdout.puts
      answer == 'y'
    end
  end
end
