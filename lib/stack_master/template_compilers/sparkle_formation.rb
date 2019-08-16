require 'stack_master/sparkle_formation/compile_time/parameters_validator'
require 'stack_master/sparkle_formation/compile_time/definitions_validator'
require 'stack_master/sparkle_formation/compile_time/state_builder'

module StackMaster::TemplateCompilers
  class SparkleFormation

    CompileTime = StackMaster::SparkleFormation::CompileTime

    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/template_file'
    end

    def self.compile(template_dir, template, compile_time_parameters, compiler_options = {})
      sparkle_template = compile_sparkle_template(template_dir, template, compiler_options)
      definitions = sparkle_template.parameters
      validate_definitions(definitions)
      validate_parameters(definitions, compile_time_parameters)

      sparkle_template.compile_time_parameter_setter do
        sparkle_template.compile_state = create_state(definitions, compile_time_parameters)
      end

      JSON.pretty_generate(sparkle_template)
    end

    private

    def self.compile_sparkle_template(template_dir, template, compiler_options)
      sparkle_path = if compiler_options['sparkle_path']
        File.expand_path(compiler_options['sparkle_path'])
      else
        template_dir
      end

      collection = ::SparkleFormation::SparkleCollection.new
      root_pack = ::SparkleFormation::Sparkle.new(
        :root => sparkle_path,
      )
      collection.set_root(root_pack)
      if compiler_options['sparkle_packs']
        compiler_options['sparkle_packs'].each do |pack_name|
          require pack_name
          pack = ::SparkleFormation::SparklePack.new(:name => pack_name)
          collection.add_sparkle(pack)
        end
      end

      if compiler_options['sparkle_pack_template']
        raise ArgumentError.new("Template #{template} not found in any sparkle pack") unless collection.templates['aws'].include? template
        template_file_path = collection.templates['aws'][template].top['path']
      else
        template_file_path = File.join(template_dir, template)
      end

      sparkle_template = compile_template_with_sparkle_path(template_file_path, sparkle_path)
      sparkle_template.sparkle.apply(collection)
      sparkle_template
    end

    def self.compile_template_with_sparkle_path(template_path, sparkle_path)
      ::SparkleFormation.sparkle_path = sparkle_path
      ::SparkleFormation.compile(template_path, :sparkle)
    end

    def self.validate_definitions(definitions)
      CompileTime::DefinitionsValidator.new(definitions).validate
    end

    def self.validate_parameters(definitions, compile_time_parameters)
      CompileTime::ParametersValidator.new(definitions, compile_time_parameters).validate
    end

    def self.create_state(definitions, compile_time_parameters)
      CompileTime::StateBuilder.new(definitions, compile_time_parameters).build
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
