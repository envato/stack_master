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

      def _user_data_file(file_name)
        file_path = File.join(File.dirname(::SparkleFormation.sparkle_path), 'templates', 'user_data', file_name)
        template = File.read(file_path)
        base64!(join!(SfEruby.new(template).evaluate(self)))
      end
      alias_method :user_data_file!, :_user_data_file
    end
  end
end
