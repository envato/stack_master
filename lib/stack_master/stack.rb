module StackMaster
  class Stack
    attr_reader :stack_name,
                :region,
                :stack_id,
                :stack_status,
                :parameters,
                :template_body,
                :template_format,
                :notification_arns,
                :outputs,
                :stack_policy_body,
                :tags,
                :files

    include Utils::Initializable

    def template_default_parameters
      TemplateUtils.template_hash(template).fetch('Parameters', {}).inject({}) do |result, (parameter_name, description)|
        result[parameter_name] = description['Default']
        result
      end
    end

    def parameters_with_defaults
      template_default_parameters.merge(parameters)
    end

    def missing_parameters?
      parameters_with_defaults.any? do |key, value|
        value == nil
      end
    end

    def self.find(region, stack_name)
      cf = StackMaster.cloud_formation_driver
      cf_stack = cf.describe_stacks(stack_name: stack_name).stacks.first
      return unless cf_stack
      parameters = cf_stack.parameters.inject({}) do |params_hash, param_struct|
        params_hash[param_struct.parameter_key] = param_struct.parameter_value
        params_hash
      end
      template_body ||= cf.get_template(stack_name: stack_name).template_body
      template_format = TemplateUtils.identify_template_format(template_body)
      stack_policy_body ||= cf.get_stack_policy(stack_name: stack_name).stack_policy_body
      outputs = cf_stack.outputs

      new(region: region,
          stack_name: stack_name,
          stack_id: cf_stack.stack_id,
          parameters: parameters,
          template_body: template_body,
          template_format: template_format,
          outputs: outputs,
          notification_arns: cf_stack.notification_arns,
          stack_policy_body: stack_policy_body,
          stack_status: cf_stack.stack_status)
    rescue Aws::CloudFormation::Errors::ValidationError
      nil
    end

    def self.generate(stack_definition, config)
      parameter_hash = ParameterLoader.load(stack_definition.parameter_files)
      template_body = TemplateCompiler.compile(config, stack_definition.template_file_path, stack_definition)
      template_format = TemplateUtils.identify_template_format(template_body)
      parameters = ParameterResolver.resolve(config, stack_definition, parameter_hash)
      stack_policy_body = if stack_definition.stack_policy_file_path
                            File.read(stack_definition.stack_policy_file_path)
                          end
      new(region: stack_definition.region,
          stack_name: stack_definition.stack_name,
          tags: stack_definition.tags,
          parameters: parameters,
          template_body: template_body,
          template_format: template_format,
          notification_arns: stack_definition.notification_arns,
          stack_policy_body: stack_policy_body)
    end

    def max_template_size(use_s3)
      return TemplateUtils::MAX_S3_TEMPLATE_SIZE if use_s3
      TemplateUtils::MAX_TEMPLATE_SIZE
    end

    def too_big?(use_s3 = false)
      template.size > max_template_size(use_s3)
    end

    def aws_parameters
      Utils.hash_to_aws_parameters(parameters)
    end

    def aws_tags
      Utils.hash_to_aws_tags(tags)
    end

    def template
      @template ||= TemplateUtils.maybe_compressed_template_body(template_body)
    end
  end
end
