module StackMaster::TemplateCompilers
  class Cfndsl

    def self.compile(template_file_path)
      load_cfndsl
      CfnDsl.eval_file_with_extras(template_file_path).to_json
    end

    def self.load_cfndsl
      require 'cfndsl'
    rescue LoadError => e
      StackMaster.stderr.puts(CFNDSL_LOAD_ERROR_MSG)
      raise e
    end
    private_class_method :load_cfndsl

    CFNDSL_LOAD_ERROR_MSG='Couldn\'t load cfndsl. Make sure you have the cfndsl gem installed, if you want to use cfndsl templates with SM.'

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end