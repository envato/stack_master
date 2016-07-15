require 'sparkle_formation'
require 'erubis'

class SparkleFormation
  module SparkleAttribute
    module Aws
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
        include SparkleAttribute
        include SparkleAttribute::Aws
        include Utils::TypeCheckers

        def initialize(vars)
          vars.each do |key, value|
            self.class.send(:define_method, key) do
              value
            end
          end
          self._camel_keys = true
        end
      end

      UserDataFileNotFound = Class.new(StandardError)

      def _user_data_file(file_name, vars = {})
        file_path = File.join(::SparkleFormation.sparkle_path, 'user_data', file_name)
        template = File.read(file_path)
        template_context = TemplateContext.new(vars)
        compiled_template = SfEruby.new(template).evaluate(template_context)
        base64!(join!(_format_user_data_for_cf(compiled_template)))
      rescue Errno::ENOENT => e
        Kernel.raise UserDataFileNotFound, "Could not find user data file at path: #{file_path}"
      end
      alias_method :user_data_file!, :_user_data_file

      # To split each user data line to it's own string in the final CF JSON array
      def _format_user_data_for_cf(compiled_template)
        compiled_template.flat_map do |lines|
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
  end
end
