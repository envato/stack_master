require "diffy"

module StackMaster
  class StackDiffer
    def initialize(proposed_stack, current_stack)
      @proposed_stack = proposed_stack
      @current_stack = current_stack
    end

    def proposed_template
      return @proposed_stack.template_body unless @proposed_stack.template_format == :json
      JSON.pretty_generate(JSON.parse(@proposed_stack.template_body))
    end

    def current_template
      return '' unless @current_stack
      return @current_stack.template_body unless @current_stack.template_format == :json
      JSON.pretty_generate(TemplateUtils.template_hash(@current_stack.template_body))
    end

    def current_parameters
      if @current_stack
        YAML.dump(sort_params(@current_stack.parameters_with_defaults))
      else
        ''
      end
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
      body_diff != ''
    end

    def body_diff
      @body_diff ||= Diffy::Diff.new(current_template, proposed_template, context: 7, include_diff_info: true).to_s
    end

    def params_different?
      params_diff != ''
    end

    def params_diff
      @param_diff ||= Diffy::Diff.new(current_parameters, proposed_parameters, {}).to_s
    end

    def output_diff
      display_diff('Stack', body_diff)
      display_diff('Parameters', params_diff)
      unless noecho_keys.empty?
        StackMaster.stdout.puts " * can not tell if NoEcho parameters are different."
      end
      StackMaster.stdout.puts "No stack found" if @current_stack.nil?
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

    def display_diff(thing, diff)
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
