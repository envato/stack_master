module StackMaster
  class StackDefinition
    include Virtus.value_object(strict: true, required: false)

    values do
      attribute :region, String
      attribute :stack_name, String
      attribute :template, String
      attribute :tags, Hash
      attribute :notification_arns, Array[String]
      attribute :base_dir, String
      attribute :secret_file, String
      attribute :files, Array[String]
      attribute :stack_policy_file, String
      attribute :additional_parameter_lookup_dirs, Array[String]
    end

    def template_dir
      File.join(base_dir, 'templates')
    end

    def template_file_path
      File.join(template_dir, template)
    end

    def files_to_upload
      files.map do |file|
        "#{template_dir}/#{file}"
      end
    end

    def parameter_files
      [ default_parameter_file_path, region_parameter_file_path ] + additional_parameter_lookup_file_paths
    end

    def stack_policy_file_path
      File.join(base_dir, 'policies', stack_policy_file) if stack_policy_file
    end

    private

    def additional_parameter_lookup_file_paths
      additional_parameter_lookup_dirs.map do |a|
        File.join(base_dir, 'parameters', a, "#{underscored_stack_name}.yml")
      end
    end

    def region_parameter_file_path
      File.join(base_dir, 'parameters', "#{region}", "#{underscored_stack_name}.yml")
    end

    def default_parameter_file_path
      File.join(base_dir, 'parameters', "#{underscored_stack_name}.yml")
    end

    def underscored_stack_name
      stack_name.gsub('-', '_')
    end
  end
end
