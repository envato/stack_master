require 'sparkle_formation'
require 'erubis'

module StackMaster
  module SparkleFormation
    LambdaCodeFileNotFound = ::Class.new(StandardError)

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

    module LambdaCode
      def _lambda_code(file_name, vars = {})
        file_path = File.join(::SparkleFormation.sparkle_path, 'lambda_functions', file_name)
        # If it's a file, process as a template and attach
        template = File.read(file_path)
        template_context = TemplateContext.build(vars)
        compiled_template = SfEruby.new(template).evaluate(template_context)[0]
        # Logic is, if the supplied thing is a file then compile it as a tempalte
        STDERR.puts("TEMPLATE TEXT IS "+compiled_template)
        compiled_template
      rescue Errno::ENOENT => e
        Kernel.raise LambdaCodeFileNotFound, "Could not find lambda function data file at path: #{file_path}"
      end
      alias_method :lambda_code!, :_lambda_code
    end
  end
end

SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::LambdaCode)
