module StackMaster
  class StackDefinition
    attr_accessor :region,
                  :stack_name,
                  :template,
                  :tags,
                  :notification_arns,
                  :base_dir,
                  :secret_file,
                  :stack_policy_file,
                  :additional_parameter_lookup_dirs,
                  :s3,
                  :files

    include Utils::Initializable

    def initialize(attributes = {})
      @additional_parameter_lookup_dirs = []
      @notification_arns = []
      @s3 = {}
      @files = []
      super
    end

    def ==(other)
      self.class === other &&
        @region == other.region &&
        @stack_name == other.stack_name &&
        @template == other.template &&
        @tags == other.tags &&
        @notification_arns == other.notification_arns &&
        @base_dir == other.base_dir &&
        @secret_file == other.secret_file &&
        @stack_policy_file == other.stack_policy_file &&
        @additional_parameter_lookup_dirs == other.additional_parameter_lookup_dirs &&
        @s3 == other.s3
    end

    def template_dir
      File.join(base_dir, 'templates')
    end

    def template_file_path
      File.join(template_dir, template)
    end

    def s3_files
      files.inject({}) do |hash, file|
        path = File.join(template_dir, file)
        hash[file] = {
          path: path,
          body: File.read(path)
        }
        hash
      end
    end

    def parameter_files
      [ default_parameter_file_path, region_parameter_file_path, additional_parameter_lookup_file_paths ].flatten.compact
    end

    def stack_policy_file_path
      File.join(base_dir, 'policies', stack_policy_file) if stack_policy_file
    end

    def s3_configured?
      !s3.nil?
    end

    private

    def additional_parameter_lookup_file_paths
      return unless additional_parameter_lookup_dirs
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
