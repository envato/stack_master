module StackMaster
  class TemplateCompiler
    TemplateCompilationFailed = Class.new(RuntimeError)

    def self.compile(config, stack_definition, compile_time_parameters, compiler_options = {})
      compiler = template_compiler_for_stack(stack_definition, config)
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
    def self.template_compiler_for_stack(stack_definition, config)
      ext = if stack_definition.sparkle_pack_template
        :rb
      else
        file_ext(stack_definition.template_file_path)
      end
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
