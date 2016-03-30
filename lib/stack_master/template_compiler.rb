module StackMaster
  class TemplateCompiler

    def self.compile(config, template_file_path)
      template_compiler_for_file(template_file_path, config).compile(template_file_path)
    end

    def self.register(name, klass)
      @compilers ||= {}
      @compilers[name] = klass
    end

    # private
    def self.template_compiler_for_file(template_file_path, config)
      template_compilers = config.template_compilers
      compiler = template_compilers.fetch(file_ext(template_file_path))
      @compilers.fetch(compiler)
    end
    private_class_method :template_compiler_for_file

    def self.file_ext(template_file_path)
      File.extname(template_file_path).gsub('.', '').to_sym
    end
    private_class_method :file_ext
  end
end
