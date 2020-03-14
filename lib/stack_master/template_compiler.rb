module StackMaster
  class TemplateCompiler
    TemplateCompilationFailed = Class.new(RuntimeError)

    def self.compile(config, template_compiler, template_dir, template, compile_time_parameters, compiler_options = {})
      compiler = if template_compiler
                   find_compiler(template_compiler)
                 else
                   template_compiler_for_stack(template, config)
                 end
      compiler.require_dependencies
      compiler.compile(template_dir, template, compile_time_parameters, compiler_options)
    rescue StandardError => e
      raise TemplateCompilationFailed, "Failed to compile #{template}"
    end

    def self.register(name, klass)
      @compilers ||= {}
      @compilers[name] = klass
    end

    # private
    def self.template_compiler_for_stack(template, config)
      ext = file_ext(template)
      compiler_name = config.template_compilers.fetch(ext)
      find_compiler(compiler_name)
    end
    private_class_method :template_compiler_for_stack

    def self.file_ext(template)
      File.extname(template).gsub('.', '').to_sym
    end
    private_class_method :file_ext

    def self.find_compiler(name)
      @compilers.fetch(name.to_sym) do
        raise "Unknown compiler #{name.inspect}"
      end
    end
  end
end
