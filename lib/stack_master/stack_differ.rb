module StackMaster
  class StackDiffer
    def initialize(proposed_stack, current_stack)
      @proposed_stack = proposed_stack
      @current_stack = current_stack
    end

    def proposed_template
      JSON.pretty_generate(JSON.parse(@proposed_stack.template_body))
    end

    def current_template
      JSON.pretty_generate(@current_stack.template_hash)
    end

    def current_parameters
      YAML.dump(sort_params(@current_stack.parameters_with_defaults))
    end

    def proposed_parameters
      # **** out any secret parameters in the current stack.
      params = @proposed_stack.parameters_with_defaults
      if @current_stack
        noecho_keys.each do |key|
          params[key] = "****"
        end
      end
      YAML.dump(sort_params(params))
    end

    def body_different?
      Diffy::Diff.new(current_template, proposed_template, {}).to_s != ''
    end

    def params_different?
      Diffy::Diff.new(current_parameters, proposed_parameters, {}).to_s != ''
    end

    def output_diff
      if @current_stack
        text_diff('Stack', current_template, proposed_template, context: 7, include_diff_info: true)
        text_diff('Parameters', current_parameters, proposed_parameters)
        unless noecho_keys.empty?
          StackMaster.stdout.puts " * can not tell if NoEcho parameters are different."
        end
      else
        text_diff('Stack', '', proposed_template)
        text_diff('Parameters', '', proposed_parameters)
        StackMaster.stdout.puts "No stack found"
      end
    end

    def noecho_keys
      if @current_stack
        @current_stack.parameters_with_defaults.select do |key, value|
          value == "****"
        end.keys
      else
        []
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

    def sort_params(hash)
      hash.sort.to_h
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
