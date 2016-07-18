module StackMaster::TemplateCompilers
  class SparkleFormation
    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/user_data_file'
    end

    def self.compile(template_file_path)
      ::SparkleFormation.sparkle_path = File.dirname(template_file_path)
      JSON.pretty_generate(::SparkleFormation.compile(template_file_path))
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end