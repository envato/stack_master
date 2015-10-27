module StackMaster
  module Config
    class StackDefinition
      include Virtus.value_object(strict: true, required: false)

      values do
        attribute :region, String
        attribute :stack_name, String
        attribute :template, String
        attribute :tags, Hash
        attribute :base_dir, String
      end

      def template_body
        File.read(template_file_path)
      end

      def template_file_path
        File.join(base_dir, 'templates', template)
      end

      def parameters
        @parameters ||= ParameterLoader.load(parameter_files)
      end

      def aws_parameters
        Utils.hash_to_aws_parameters(parameters)
      end

      def aws_tags
        Utils.hash_to_aws_tags(tags)
      end

      private

      def region_parameter_file_path
        File.join(base_dir, 'parameters', "#{region}", "#{stack_name}.yml")
      end

      def default_parameter_file_path
        File.join(base_dir, 'parameters', "#{stack_name}.yml")
      end

      def parameter_files
        [ default_parameter_file_path, region_parameter_file_path ]
      end
    end
  end
end
