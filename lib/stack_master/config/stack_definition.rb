module StackMaster
  module Config
    class StackDefinition
      include Virtus.value_object(strict: true, required: false)

      values do
        attribute :region, String
        attribute :stack_name, String
        attribute :template, String
        attribute :tags, Hash
        attribute :parameter_files, Array[String]
        attribute :base_dir, String
      end

      def template_body
        File.read(template_file_path)
      end

      def template_file_path
        File.join(base_dir, 'templates', template)
      end

      def parameters
        YAML.load(File.read(parameter_file_path))
      end

      def aws_parameters
        parameters.inject([]) do |params, (key, value)|
          params << { parameter_key: key, parameter_value: value }
          params
        end
      end

      def parameter_file_path
        File.join(base_dir, 'parameters', "#{stack_name}.yml")
      end

      def aws_tags
        return [] if tags.nil?
        tags.inject([]) do |aws_tags, (key, value)|
          aws_tags << { key: key, value: value }
          aws_tags
        end
      end
    end
  end
end
