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
        parameter_files.reduce({}) do |hash, file_name|
          if File.exists?(file_name)
            parameters = YAML.load(File.read(file_name))
          else
            parameters = {}
          end
          hash.merge(parameters)
        end
      end

      def aws_parameters
        parameters.inject([]) do |params, (key, value)|
          params << { parameter_key: key, parameter_value: value }
          params
        end
      end

      def aws_tags
        return [] if tags.nil?
        tags.inject([]) do |aws_tags, (key, value)|
          aws_tags << { key: key, value: value }
          aws_tags
        end
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
