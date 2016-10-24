require 'sparkle_formation'
require 'erubis'

module StackMaster
  module SparkleFormation
    LambdaFunctionFileNotFound = ::Class.new(StandardError)

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

    module LambdaFunction
      def _lambda_function(file_name, vars = {})
        file_path = File.join(::SparkleFormation.sparkle_path, 'lambda_functions', file_name)
        template = File.read(file_path)
        template_context = TemplateContext.build(vars)
        compiled_template = SfEruby.new(template).evaluate(template_context)[0]
      rescue Errno::ENOENT => e
        Kernel.raise LambdaFunctionFileNotFound, "Could not find lambda function data file at path: #{file_path}"
      end
      alias_method :lambda_function!, :_lambda_function
    end
  end
end

SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::LambdaFunction)
