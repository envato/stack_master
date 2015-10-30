module StackMaster
  class DiffHelper
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
      JSON.pretty_generate(sort_params(@current_stack.parameters))
    end

    def proposed_parameters
      JSON.pretty_generate(sort_params(@proposed_stack.parameters))
    end

    def body_different?
      Diffy::Diff.new(current_template, proposed_template, {}).to_s != ''
    end

    def params_different?
      Diffy::Diff.new(current_parameters, proposed_parameters, {}).to_s != ''
    end

    private

    def sort_params(hash)
      hash.sort.to_h
    end

  end
end
