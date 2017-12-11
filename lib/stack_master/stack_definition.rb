module StackMaster
  class StackDefinition
    attr_accessor :environment,
                  :region,
                  :raw_stack_name,
                  :stack_name,
                  :template,
                  :tags,
                  :role_arn,
                  :notification_arns,
                  :base_dir,
                  :template_dir,
                  :secret_file,
                  :stack_policy_file,
                  :s3,
                  :files,
                  :compiler_options

    include Utils::Initializable

    def initialize(attributes = {})
      @compiler_options = {}
      @notification_arns = []
      @s3 = {}
      @files = []
      super
      @template_dir ||= File.join(@base_dir, 'templates')
      @raw_stack_name = "#{environment}-#{stack_name}"
    end

    def ==(other)
      self.class === other &&
        @environment == other.environment &&
        @region == other.region &&
        @stack_name == other.stack_name &&
        @template == other.template &&
        @tags == other.tags &&
        @role_arn == other.role_arn &&
        @notification_arns == other.notification_arns &&
        @base_dir == other.base_dir &&
        @secret_file == other.secret_file &&
        @stack_policy_file == other.stack_policy_file &&
        @s3 == other.s3 &&
        @compiler_options == other.compiler_options
    end

    def template_file_path
      File.expand_path(File.join(template_dir, template))
    end

    def files_dir
      File.join(base_dir, 'files')
    end

    def s3_files
      files.inject({}) do |hash, file|
        path = File.join(files_dir, file)
        hash[file] = {
          path: path,
          body: File.read(path)
        }
        hash
      end
    end

    def s3_template_file_name
      return template if ['.json', '.yaml', '.yml'].include?(File.extname(template))
      Utils.change_extension(template, 'json')
    end

    def parameter_files
      [ default_parameter_file_path, environment_parameter_file_path, region_parameter_file_path ].flatten.compact
    end

    def stack_policy_file_path
      File.join(base_dir, 'policies', stack_policy_file) if stack_policy_file
    end

    def s3_configured?
      !s3.nil?
    end

    private

    def region_parameter_file_path
      File.join(base_dir, 'parameters', "#{region}", "#{underscored_stack_name}.yml")
    end

    def environment_parameter_file_path
      File.join(base_dir, 'parameters', "#{environment}", "#{underscored_stack_name}.yml")
    end

    def default_parameter_file_path
      File.join(base_dir, 'parameters', "#{underscored_stack_name}.yml")
    end

    def underscored_stack_name
      stack_name.gsub('-', '_')
    end
  end
end
