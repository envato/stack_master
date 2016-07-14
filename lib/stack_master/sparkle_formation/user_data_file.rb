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

      UserDataFileNotFound = Class.new(StandardError)

      def _user_data_file(file_name)
        file_path = File.join(::SparkleFormation.sparkle_path, 'user_data', file_name)
        template = File.read(file_path)
        base64!(join!(SfEruby.new(template).evaluate(self)))
      rescue Errno::ENOENT => e
        Kernel.raise UserDataFileNotFound, "Could not find user data file at path: #{file_path}"
      end
      alias_method :user_data_file!, :_user_data_file
    end
  end
end
