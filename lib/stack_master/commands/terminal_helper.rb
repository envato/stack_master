module StackMaster
  module Commands
    module TerminalHelper
      def window_size
        size = ENV.fetch("COLUMNS") { `tput cols`.chomp }

        if size.nil? || size == ""
          80
        else
          size.to_i
        end
      end
    end
  end
end
