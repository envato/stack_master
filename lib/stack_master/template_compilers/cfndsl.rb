module StackMaster::TemplateCompilers
  class Cfndsl
    def self.require_dependencies
      require 'cfndsl'
    end

    def self.compile(config, template_file_path, cfndsl_external_parameters)
      params = []
      if cfndsl_external_parameters.is_a?
        cfndsl_external_parameters.each do |cfndsl_param|
          params.push([:yaml, File.join(config.base_dir, 'external_parameters',
                 cfndsl_param)])      
          end
      else
      params.push([:yaml, File.join(config.base_dir, 'external_parameters', 
                  cfndsl_external_parameters)]) if cfndsl_external_parameters.length > 0
      ::CfnDsl.eval_file_with_extras(template_file_path, params).to_json
      end
    end

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end
