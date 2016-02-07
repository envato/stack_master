module StackMaster
  module Prompter
    def ask?(question)
      answer = if StackMaster.interactive?
        StackMaster.stdout.print question
        if StackMaster.stdin.tty? && StackMaster.stdout.tty?
          StackMaster.stdin.getch.chomp
        else
          StackMaster.stdout.puts
          StackMaster.stdout.puts "STDOUT or STDIN was not a TTY. Defaulting to no. To force yes use -y"
          'n'
        end
      else
        StackMaster.non_interactive_answer
      end
      StackMaster.stdout.puts
      answer == 'y'
    end
  end
end
