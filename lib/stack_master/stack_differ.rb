module StackMaster
  class StackDiffer
    include Command

    def initialize(proposed_stack, stack)
      @proposed_stack = proposed_stack
      @stack = stack
      @context = 7
      @diff = DiffHelper.new(@proposed_stack, @stack)
    end

    def perform
      if @stack
        text_diff('Stack', @diff.current_template, @diff.proposed_template, context: @context, include_diff_info: true)
        text_diff('Parameters', @diff.current_parameters, @diff.proposed_parameters)
      else
        text_diff('Stack', '', @diff.proposed_template)
        text_diff('Parameters', '', @diff.proposed_parameters)
        StackMaster.stdout.puts "No stack found"
      end
    end

    private

    def text_diff(thing, current, proposed, diff_opts = {})
      diff = Diffy::Diff.new(current, proposed, diff_opts).to_s
      StackMaster.stdout.print "#{thing} diff: "
      if diff == ''
        StackMaster.stdout.puts "No changes"
      else
        StackMaster.stdout.puts
        diff.each_line do |line|
          if line.start_with?('+')
            StackMaster.stdout.print colorize(line, :green)
          elsif line.start_with?('-')
            StackMaster.stdout.print colorize(line, :red)
          else
            StackMaster.stdout.print line
          end
        end
      end
    end

    def colorize(text, color)
      if colorize?
        text.colorize(color)
      else
        text
      end
    end

    def colorize?
      ENV.fetch('COLORIZE') { 'true' } == 'true'
    end

  end
end
