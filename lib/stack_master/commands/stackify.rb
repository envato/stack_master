module StackMaster
  module Commands
    class Stackify
      include Command
      include Commander::UI

      def initialize(input_data)
        @input_data = input_data
      end

      def perform
        generate_output(JSON.parse(@input_data))
      end

      private

      def generate_output(input, depth=0)
        indent = " " * (depth * 2)
        output = []
        if Hash === input
          input.each do |k,v|
            k = k.underscore
            if k == 'resources'
              v.each do |rk,rv|
                output << "#{indent}resources.#{rk.underscore} do"
                output += generate_output(rv, depth+1)
                output << "#{indent}end"
              end
            elsif Array === v
              if v.all?{|x| Hash === x}
                output << "#{indent}#{k} _array("
                output += generate_output(v, depth+1)
                output << "#{indent})"
              else
                output << "#{indent}#{k} #{v.to_s}"
              end
            elsif Hash === v
              output << "#{indent}#{k} do"
              output += generate_output(v, depth+1)
              output << "#{indent}end"
            elsif String === v
              output << "#{indent}#{k} '#{v}'"
            else
              output << "#{indent}#{k} #{v}"
            end
          end
        elsif Array === input
          input.each do |x|
            output << "#{indent}-> {"
            output += generate_output(x, depth+1)
            output << "#{indent}},"
          end
        else
          output << "#{indent}'#{input}'"
        end
        output
      end

    end
  end
end
