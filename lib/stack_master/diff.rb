module StackMaster
  class Diff
    def initialize(before:, after:, name: nil, context: 10_000)
      @name = name
      @before = before
      @after = after
      @context = context
    end

    def display
      stdout.print "#{@name} diff: "
      if diff == ''
        stdout.puts "No changes"
      else
        stdout.puts
        display_colorized_diff
      end
    end

    def display_colorized_diff
      diff.each_line do |line|
        if line.start_with?('+')
          stdout.print colorize(line, :green)
        elsif line.start_with?('-')
          stdout.print colorize(line, :red)
        else
          stdout.print line
        end
      end
    end

    def different?
      diff != ''
    end

    private

    def diff
      @diff ||= Diffy::Diff.new(@before, @after, context: @context).to_s
    end

    extend Forwardable
    def_delegators :StackMaster, :colorize, :stdout
  end
end
