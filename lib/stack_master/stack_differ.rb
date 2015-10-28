module StackMaster
  class StackDiffer
    include Command

    def initialize(proposed_stack, stack)
      @proposed_stack = proposed_stack
      @stack = stack
      @context = 7
    end

    def perform
      resolved_parameters = JSON.pretty_generate(sort_params(@proposed_stack.parameters))
      if @stack
        text_diff('Stack', JSON.pretty_generate(@stack.template_hash), JSON.pretty_generate(JSON.parse(@proposed_stack.template_body)), context: @context, include_diff_info: true)
        text_diff('Parameters', JSON.pretty_generate(sort_params(@stack.parameters)), resolved_parameters)
      else
        text_diff('Stack', '', JSON.pretty_generate(JSON.parse(@proposed_stack.template_body)))
        text_diff('Parameters', '', resolved_parameters)
        puts "No stack found"
      end
    end

    private

    def sort_params(hash)
      hash.sort.to_h
    end

    def text_diff(thing, current, proposed, diff_opts = {})
      diff = Diffy::Diff.new(current, proposed, diff_opts).to_s
      print "#{thing} diff: "
      if diff == ''
        puts "No changes"
      else
        puts
        diff.each_line do |line|
          if line.start_with?('+')
            print colorize(line, :green)
          elsif line.start_with?('-')
            print colorize(line, :red)
          else
            print line
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
