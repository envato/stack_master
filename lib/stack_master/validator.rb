module StackMaster
  class Validator
    def self.valid?(stack_definition, config, options)
      new(stack_definition, config, options).perform
    end

    def initialize(stack_definition, config, options)
      @stack_definition = stack_definition
      @config = config
      @options = options
    end

    def perform
      StackMaster.stdout.print "#{@stack_definition.stack_name}: "
      if validate_template_parameters? && parameter_validator.missing_parameters?
        StackMaster.stdout.puts "invalid\n#{parameter_validator.error_message}"
        return false
      end
      cf.validate_template(template_body: TemplateUtils.maybe_compressed_template_body(stack.template_body))
      StackMaster.stdout.puts "valid"
      true
    rescue Aws::CloudFormation::Errors::ValidationError => e
      StackMaster.stdout.puts "invalid. #{e.message}"
      false
    end

    private

    def validate_template_parameters?
      @options.validate_template_parameters
    end

    def cf
      @cf ||= StackMaster.cloud_formation_driver
    end

    def stack
      @stack ||= if validate_template_parameters?
        Stack.generate(@stack_definition, @config)
      else
        Stack.generate_without_parameters(@stack_definition, @config)
      end
    end

    def parameter_validator
      @parameter_validator ||= ParameterValidator.new(stack: stack, stack_definition: @stack_definition)
    end
  end
end
