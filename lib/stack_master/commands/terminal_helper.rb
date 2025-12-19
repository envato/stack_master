require 'os'

module StackMaster
  module Commands
    module TerminalHelper
      def window_size
        size = ENV.fetch('COLUMNS') { OS.windows? ? windows_window_size : unix_window_size }

        if size.nil? || size == ''
          80
        else
          size.to_i
        end
      end

      def unix_window_size
        `tput cols`.chomp
      end

      def windows_window_size
        columns_regex = /^\s+Columns:\s+([0-9]+)$/
        output = `mode con`
        columns_line = output.split("\n").select { |line| line.match(columns_regex) }.last
        columns_line.match(columns_regex)[1]
      end
    end
  end
end
