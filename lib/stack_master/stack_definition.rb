module StackMaster
  class StackDefinition
    attr_accessor :region,
                  :stack_name,
                  :template,
                  :tags,
                  :role_arn,
                  :allowed_accounts,
                  :notification_arns,
                  :base_dir,
                  :template_dir,
                  :ejson_file,
                  :ejson_file_region,
                  :ejson_file_kms,
                  :stack_policy_file,
                  :additional_parameter_lookup_dirs,
                  :s3,
                  :files,
                  :compiler_options

    attr_reader :compiler

    include Utils::Initializable

    def initialize(attributes = {})
      @additional_parameter_lookup_dirs = []
      @compiler_options = {}
      @notification_arns = []
      @s3 = {}
      @files = []
      @allowed_accounts = nil
      @ejson_file_kms = true
      @compiler = nil
      super
      @template_dir ||= File.join(@base_dir, 'templates')
      @allowed_accounts = Array(@allowed_accounts)
    end

    def ==(other)
      self.class === other &&
        @region == other.region &&
        @stack_name == other.stack_name &&
        @template == other.template &&
        @tags == other.tags &&
        @role_arn == other.role_arn &&
        @allowed_accounts == other.allowed_accounts &&
        @notification_arns == other.notification_arns &&
        @base_dir == other.base_dir &&
        @ejson_file == other.ejson_file &&
        @ejson_file_region == other.ejson_file_region &&
        @ejson_file_kms == other.ejson_file_kms &&
        @stack_policy_file == other.stack_policy_file &&
        @additional_parameter_lookup_dirs == other.additional_parameter_lookup_dirs &&
        @s3 == other.s3 &&
        @compiler == other.compiler &&
        @compiler_options == other.compiler_options
    end

    def compiler=(compiler)
      @compiler = compiler.&to_sym
    end

    def template_file_path
      return unless template
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
        Dir.glob(File.join(base_dir, 'parameters', a, "#{underscored_stack_name}.y*ml"))
      end
    end

    def region_parameter_file_path
      Dir.glob(File.join(base_dir, 'parameters', "#{region}", "#{underscored_stack_name}.y*ml"))
    end

    def default_parameter_file_path
      Dir.glob(File.join(base_dir, 'parameters', "#{underscored_stack_name}.y*ml"))
    end

    def underscored_stack_name
      stack_name.gsub('-', '_')
    end
  end
end
