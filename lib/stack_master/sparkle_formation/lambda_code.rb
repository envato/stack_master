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
        #STDERR.puts(file_path)
        # If it's a file, process as a template and attach if it's a directory zip and upload it to s3
        if File.file?(file_path) then
          template = File.read(file_path)
          template_context = TemplateContext.build(vars)
          compiled_template = SfEruby.new(template).evaluate(template_context)[0]
        elsif File.directory?(file_path)
          s3 = StackMaster.s3_driver
          s3.upload_files(
            bucket: 'envato-hack-fort-lambda-functions',
            prefix: 'stack_master',
            region: 'us-east-1',
            files: File.join(::SparkleFormation.sparkle_path, 'lambda_functions', file_name)
          )
          s3.url(
            bucket: 'envato-hack-fort-lambda-functions',
            prefix: 'stack_master',
            region: 'us-east-1',
            template: file_name+".zip"
          )
        else
          Kernel.raise LambdaCodeFileNotFound, "Could not find lambda function data file at path: #{file_path}"
        end
      rescue Errno::ENOENT => e
        Kernel.raise LambdaCodeFileNotFound, "Could not find lambda function data file at path: #{file_path}"
      end
      alias_method :lambda_code!, :_lambda_code
    end
  end
end

SparkleFormation::SparkleAttribute::Aws.send(:include, StackMaster::SparkleFormation::LambdaCode)
