module StackMaster::TemplateCompilers
  class SparkleFormation
    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/template_file'
    end

    def self.compile(template_file_path, compiler_options = {})
      if compiler_options["sparkle_path"]
        ::SparkleFormation.sparkle_path = File.expand_path(compiler_options["sparkle_path"])
      else
        ::SparkleFormation.sparkle_path = File.dirname(template_file_path)
      end

      JSON.pretty_generate(::SparkleFormation.compile(template_file_path))
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
