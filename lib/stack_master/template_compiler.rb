module StackMaster
  class TemplateCompiler
    TemplateCompilationFailed = Class.new(RuntimeError)

    def self.compile(config, template_file_path, cfndsl_external_parameters)
      compiler = template_compiler_for_file(template_file_path, config)
      compiler.require_dependencies
      compiler.compile(config, template_file_path, cfndsl_external_parameters)
    rescue
      raise TemplateCompilationFailed.new("Failed to compile #{template_file_path}.")
    end

    def self.register(name, klass)
      @compilers ||= {}
      @compilers[name] = klass
    end

    # private
    def self.template_compiler_for_file(template_file_path, config)
      compiler_name = config.template_compilers.fetch(file_ext(template_file_path))
      @compilers.fetch(compiler_name)
    end
    private_class_method :template_compiler_for_file

    def self.file_ext(template_file_path)
      File.extname(template_file_path).gsub('.', '').to_sym
    end
    private_class_method :file_ext
  end
end
