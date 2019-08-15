module StackMaster
  class TemplateCompiler
    TemplateCompilationFailed = Class.new(RuntimeError)

    def self.compile(config, stack_definition, compile_time_parameters, compiler_options = {})
      compiler = if stack_definition.sparkle_pack_template
        sparkle_template_compiler(config)
      else
        template_compiler_for_file(stack_definition.template_file_path, config)
      end
      compiler.require_dependencies
      compiler.compile(stack_definition, compile_time_parameters, compiler_options)
    rescue StandardError => e
      raise TemplateCompilationFailed.new("Failed to compile #{stack_definition.template_file_path} with error #{e}.\n#{e.backtrace}")
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

    # private
    def self.sparkle_template_compiler(config)
      compiler_name = config.template_compilers.fetch(:rb)
      @compilers.fetch(compiler_name)
    end
    private_class_method :template_compiler_for_file

    def self.file_ext(template_file_path)
      File.extname(template_file_path).gsub('.', '').to_sym
    end
    private_class_method :file_ext
  end
end
