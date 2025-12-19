module StackMaster
  class Stack
    attr_reader :stack_name,
                :region,
                :stack_id,
                :stack_status,
                :parameters,
                :template_body,
                :template_format,
                :role_arn,
                :notification_arns,
                :outputs,
                :stack_policy_body,
                :tags,
                :files

    include Utils::Initializable

    def template_default_parameters
      TemplateUtils
        .template_hash(template)
        .fetch('Parameters', {})
        .each_with_object({}) do |(parameter_name, description), result|
          result[parameter_name] = description['Default']&.to_s
        end
    end

    def parameters_with_defaults
      template_default_parameters.merge(parameters)
    end

    def self.find(region, stack_name)
      cf = StackMaster.cloud_formation_driver
      cf_stack = cf.describe_stacks({ stack_name: stack_name }).stacks.first
      return unless cf_stack

      parameters = cf_stack.parameters.each_with_object({}) do |param_struct, params_hash|
        params_hash[param_struct.parameter_key] = param_struct.parameter_value
      end
      template_body ||= cf.get_template({ stack_name: stack_name, template_stage: 'Original' }).template_body
      template_format = TemplateUtils.identify_template_format(template_body)
      stack_policy_body ||= cf.get_stack_policy({ stack_name: stack_name }).stack_policy_body
      outputs = cf_stack.outputs
      tags = cf_stack.tags&.each_with_object({}) do |tag_struct, tags_hash|
        tags_hash[tag_struct.key] = tag_struct.value
      end || {}

      new(region: region,
          stack_name: stack_name,
          stack_id: cf_stack.stack_id,
          parameters: parameters,
          tags: tags,
          template_body: template_body,
          template_format: template_format,
          outputs: outputs,
          role_arn: cf_stack.role_arn,
          notification_arns: cf_stack.notification_arns,
          stack_policy_body: stack_policy_body,
          stack_status: cf_stack.stack_status)
    rescue Aws::CloudFormation::Errors::ValidationError
      nil
    end

    def self.generate(stack_definition, config)
      parameter_hash = ParameterLoader.load(
        parameter_files: stack_definition.all_parameter_files,
        parameters: stack_definition.parameters
      )
      template_parameters = ParameterResolver.resolve(config, stack_definition, parameter_hash[:template_parameters])
      compile_time_parameters = ParameterResolver.resolve(
        config,
        stack_definition,
        parameter_hash[:compile_time_parameters]
      )
      template_body = TemplateCompiler.compile(
        config,
        stack_definition.compiler,
        stack_definition.template_dir,
        stack_definition.template,
        compile_time_parameters,
        stack_definition.compiler_options
      )
      template_format = TemplateUtils.identify_template_format(template_body)
      stack_policy_body =
        (File.read(stack_definition.stack_policy_file_path) if stack_definition.stack_policy_file_path)
      new(region: stack_definition.region,
          stack_name: stack_definition.stack_name,
          tags: stack_definition.tags,
          parameters: template_parameters,
          template_body: template_body,
          template_format: template_format,
          role_arn: stack_definition.role_arn,
          notification_arns: stack_definition.notification_arns,
          stack_policy_body: stack_policy_body)
    end

    def self.generate_without_parameters(stack_definition, config)
      parameter_hash = ParameterLoader.load(
        parameter_files: stack_definition.all_parameter_files,
        parameters: stack_definition.parameters
      )
      compile_time_parameters = ParameterResolver.resolve(
        config,
        stack_definition,
        parameter_hash[:compile_time_parameters]
      )
      template_body = TemplateCompiler.compile(
        config,
        stack_definition.compiler,
        stack_definition.template_dir,
        stack_definition.template,
        compile_time_parameters,
        stack_definition.compiler_options
      )
      template_format = TemplateUtils.identify_template_format(template_body)
      stack_policy_body =
        (File.read(stack_definition.stack_policy_file_path) if stack_definition.stack_policy_file_path)
      new(region: stack_definition.region,
          stack_name: stack_definition.stack_name,
          tags: stack_definition.tags,
          parameters: {},
          template_body: template_body,
          template_format: template_format,
          role_arn: stack_definition.role_arn,
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
