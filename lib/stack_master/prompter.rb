module StackMaster
  module Prompter
    def ask?(question)
      StackMaster.stdout.print question
      answer = if StackMaster.interactive?
        if StackMaster.stdin.tty?
          StackMaster.stdin.getch.chomp
        else
          StackMaster.stdout.puts "STDOUT was not a TTY. Defaulting to no. To force yes use -f"
          'n'
        end
      else
        ENV.fetch('ANSWER') { 'y' }
      end
      StackMaster.stdout.puts
      answer == 'y'
    end
  end
end
