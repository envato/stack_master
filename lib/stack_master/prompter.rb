module StackMaster
  module Prompter
    def ask?(question)
      answer = if StackMaster.interactive?
        StackMaster.stdout.print question
        if StackMaster.stdin.tty? && StackMaster.stdout.tty?
          StackMaster.stdin.getch.chomp
        else
          StackMaster.stdout.puts
          StackMaster.stdout.puts "STDOUT or STDIN was not a TTY. Defaulting to no. To force yes use -f"
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
