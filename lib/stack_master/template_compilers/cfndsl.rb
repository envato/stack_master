module StackMaster::TemplateCompilers
  class Cfndsl
    def self.require_dependencies
      require 'cfndsl'
    end

    def self.compile(config, template_file_path, stack_definition)
      params = []
      params.push([:yaml, File.join(config.base_dir, 'external_parameters', stack_definition.cfndsl_external_parameters)]) if stack_definition.cfndsl_external_parameters.length > 0
      ::CfnDsl.eval_file_with_extras(template_file_path, params).to_json
    end

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end
