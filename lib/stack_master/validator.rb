module StackMaster
  class Validator
    def self.valid?(stack_definition, config)
      new(stack_definition, config).perform
    end

    def initialize(stack_definition, config)
      @stack_definition = stack_definition
      @config = config
    end

    def perform
      parameter_hash = ParameterLoader.load(@stack_definition.parameter_files)
      compile_time_parameters = ParameterResolver.resolve(@config, @stack_definition, parameter_hash[:compile_time_parameters])

      StackMaster.stdout.print "#{@stack_definition.stack_name}: "
      template_body = TemplateCompiler.compile(@config, @stack_definition.template_dir, @stack_definition.template, compile_time_parameters, @stack_definition.compiler_options)
      cf.validate_template(template_body: TemplateUtils.maybe_compressed_template_body(template_body))
      StackMaster.stdout.puts "valid"
      true
    rescue Aws::CloudFormation::Errors::ValidationError => e
      StackMaster.stdout.puts "invalid. #{e.message}"
      false
    end

    private

    def cf
      @cf ||= StackMaster.cloud_formation_driver
    end
  end
end
