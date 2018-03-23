module StackMaster::TemplateCompilers
  class Cfndsl
    def self.require_dependencies
      require 'cfndsl'
    end

    def self.compile(template_file_path, _compile_time_parameters, _compiler_options = {})
      CfnDsl.disable_binding
      CfnDsl::ExternalParameters.defaults(_compile_time_parameters.symbolize_keys)
      ::CfnDsl.eval_file_with_extras(template_file_path).to_json
    end

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end
