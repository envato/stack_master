require 'sparkle_formation'
require 'erubis'

module StackMaster
  module SparkleFormation
    TemplateFileNotFound = ::Class.new(StandardError)

    class TemplateContext < AttributeStruct
      include ::SparkleFormation::SparkleAttribute
      include ::SparkleFormation::SparkleAttribute::Aws
      include ::SparkleFormation::Utils::TypeCheckers

      def self.build(vars, prefix)
        ::Class.new(self).tap do |klass|
          vars.each do |key, value|
            klass.send(:define_method, key) do
              value
            end
          end
        end.new(vars, prefix)
      end

      def initialize(vars, prefix)
        self._camel_keys = true
        @vars = vars
        @prefix = prefix
      end

      def has_var?(var_key)
        @vars.include?(var_key)
      end

      def render(file_name, vars = {})
        Template.render(@prefix, file_name, vars)
      end
    end

    module Template
      def self.render(prefix, file_name, vars)
        file_path = File.join(::SparkleFormation.sparkle_path, prefix, file_name)
        template_context = TemplateContext.build(vars, prefix)
        CloudFormationInterpolatingEruby.evaluate_file(file_path, template_context)
      rescue Errno::ENOENT
        Kernel.raise TemplateFileNotFound, "Could not find template file at path: #{file_path}"
      end
    end

    module JoinedFile
      def _joined_file(file_name, vars = {})
        join!(Template.render('joined_file', file_name, vars))
      end
      alias joined_file! _joined_file
    end

    module UserDataFile
      def _user_data_file(file_name, vars = {})
        base64!(join!(Template.render('user_data', file_name, vars)))
      end
      alias user_data_file! _user_data_file
    end
  end
end

SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::UserDataFile)
SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::JoinedFile)
