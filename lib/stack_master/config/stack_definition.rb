module StackMaster
  class Config
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
      end

      def template_file_path
        File.join(base_dir, 'templates', template)
      end

      def parameter_files
        [ default_parameter_file_path, region_parameter_file_path ]
      end

      private

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
end
