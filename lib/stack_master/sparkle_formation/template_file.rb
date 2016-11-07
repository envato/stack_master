require 'sparkle_formation'
require 'erubis'

module StackMaster
  module SparkleFormation
    TemplateFileNotFound = ::Class.new(StandardError)

    class SfEruby < Erubis::Eruby
      include Erubis::ArrayEnhancer

      def add_expr(src, code, indicator)
        case indicator
          when '='
            src << " #{@bufvar} << (" << code << ');'
          else
            super
        end
      end
    end

    class TemplateContext < AttributeStruct
      include ::SparkleFormation::SparkleAttribute
      include ::SparkleFormation::SparkleAttribute::Aws
      include ::SparkleFormation::Utils::TypeCheckers

      def self.build(vars)
        ::Class.new(self).tap do |klass|
          vars.each do |key, value|
            klass.send(:define_method, key) do
              value
            end
          end
        end.new(vars)
      end

      def initialize(vars)
        self._camel_keys = true
        @vars = vars
      end

      def has_var?(var_key)
        @vars.include?(var_key)
      end
    end

    # Splits up long strings with multiple lines in them to multiple strings
    # in the CF array. Makes the compiled template and diffs more readable.
    class CloudFormationLineFormatter
      def self.format(template)
        new(template).format
      end

      def initialize(template)
        @template = template
      end

      def format
        @template.flat_map do |lines|
          lines = lines.to_s if Symbol === lines
          if String === lines
            newlines = []
            lines.count("\n").times do
              newlines << "\n"
            end
            newlines = lines.split("\n").map do |line|
              "#{line}#{newlines.pop}"
            end
            if lines.starts_with?("\n")
              newlines.insert(0, "\n")
            end
            newlines
          else
            lines
          end
        end
      end
    end

    module Template
      def self.render(prefix, file_name, vars)
        file_path = File.join(::SparkleFormation.sparkle_path, prefix, file_name)
        template = File.read(file_path)
        template_context = TemplateContext.build(vars)
        compiled_template = SfEruby.new(template).evaluate(template_context)
        CloudFormationLineFormatter.format(compiled_template)
      rescue Errno::ENOENT => e
        Kernel.raise TemplateFileNotFound, "Could not find user data file at path: #{file_path}"
      end
    end

    module ConfigFile
      def _config_file(file_name, vars = {})
        join!(Template.render('config', file_name, vars))
      end
      alias_method :config_file!, :_config_file
    end

    module UserDataFile
      def _user_data_file(file_name, vars = {})
        base64!(join!(Template.render('user_data', file_name, vars)))
      end
      alias_method :user_data_file!, :_user_data_file
    end
  end
end

SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::UserDataFile)
SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::ConfigFile)

