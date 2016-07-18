module StackMaster::TemplateCompilers
  class Cfndsl
    def self.require_dependencies
      require 'cfndsl'
    end

    def self.compile(template_file_path, compiler_options={})
      ::CfnDsl.eval_file_with_extras(template_file_path).to_json
    end

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end
