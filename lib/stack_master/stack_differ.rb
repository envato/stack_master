require "diffy"
require "hashdiff"

module StackMaster
  class StackDiffer
    def initialize(proposed_stack, current_stack)
      @proposed_stack = proposed_stack
      @current_stack = current_stack
    end

    def proposed_template
      return @proposed_stack.template_body unless @proposed_stack.template_format == :json

      JSON.pretty_generate(JSON.parse(@proposed_stack.template_body)) + "\n"
    end

    def current_template
      return '' unless @current_stack
      return @current_stack.template_body unless @current_stack.template_format == :json

      JSON.pretty_generate(TemplateUtils.template_hash(@current_stack.template_body)) + "\n"
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
      body_diff.different?
    end

    def body_diff
      @body_diff ||= Diff.new(name: 'Stack',
                              before: current_template,
                              after: proposed_template,
                              context: 7)
    end

    def params_different?
      parameters_diff.different?
    end

    def parameters_diff
      @param_diff ||= Diff.new(name: 'Parameters',
                               before: current_parameters,
                               after: proposed_parameters)
    end

    def output_diff
      body_diff.display
      parameters_diff.display

      StackMaster.stdout.puts " * can not tell if NoEcho parameters are different." unless noecho_keys.empty?
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

    def single_param_update?(param_name)
      return false if param_name.blank? || @current_stack.blank? || body_different?

      differences = Hashdiff.diff(@current_stack.parameters_with_defaults, @proposed_stack.parameters_with_defaults)
      return false if differences.count != 1

      diff = differences[0]
      diff[0] == "~" && diff[1] == param_name
    end

    private

    def sort_params(hash)
      hash.sort.to_h
    end
  end
end
