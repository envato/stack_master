module StackMaster
  class TemplateCompiler
    TemplateCompilationFailed = Class.new(RuntimeError)

    def self.compile(config, template_dir, template_file_path, compile_time_parameters, compiler_options = {})
      compiler = template_compiler_for_stack(template_file_path, config)
      compiler.require_dependencies
      compiler.compile(template_dir, template_file_path, compile_time_parameters, compiler_options)
    rescue StandardError => e
      raise TemplateCompilationFailed.new("Failed to compile #{template_file_path} with error #{e}.\n#{e.backtrace}")
    end

    def self.register(name, klass)
      @compilers ||= {}
      @compilers[name] = klass
    end

    # private
    def self.template_compiler_for_stack(template_file_path, config)
      ext = file_ext(template_file_path)
      compiler_name = config.template_compilers.fetch(ext)
      @compilers.fetch(compiler_name)
    end
    private_class_method :template_compiler_for_stack

    def self.file_ext(template_file_path)
      File.extname(template_file_path).gsub('.', '').to_sym
    end
    private_class_method :file_ext
  end
end
