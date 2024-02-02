# frozen_string_literal: true

require 'erubis'

module StackMaster
  #  This class is a modified version of `Erubis::Eruby`. It allows using
  # `<%= %>` ERB expressions to interpolate values into a source string. We use
  # this capability to enrich user data scripts with data and parameters pulled
  # from the AWS CloudFormation service. The evaluation produces an array of
  # objects ready for use in a CloudFormation `Fn::Join` intrinsic function.
  class CloudFormationInterpolatingEruby < Erubis::Eruby
    include Erubis::ArrayEnhancer

    # Load a template from a file at the specified path and evaluate it.
    def self.evaluate_file(source_path, context = Erubis::Context.new)
      template_contents = File.read(source_path)
      eruby = new(template_contents)
      eruby.filename = source_path
      eruby.evaluate(context)
    end

    # @return [Array] The result of evaluating the source: an array of strings
    #         from the source intermindled with Hash objects from the ERB
    #         expressions. To be included in a CloudFormation template, this
    #         value needs to be used in a CloudFormation `Fn::Join` intrinsic
    #         function.
    # @see Erubis::Eruby#evaluate
    # @example
    #   CloudFormationInterpolatingEruby.new("my_variable=<%= { 'Ref' => 'Param1' } %>;").evaluate
    #     #=> ['my_variable=', { 'Ref' => 'Param1' }, ';']
    def evaluate(_context = Erubis::Context.new)
      format_lines_for_cloudformation(super)
    end

    # @see Erubis::Eruby#add_expr
    def add_expr(src, code, indicator)
      if indicator == '='
        src << " #{@bufvar} << (" << code << ');'
      else
        super
      end
    end

    private

    # Split up long strings containing multiple lines. One string per line in the
    # CloudFormation array makes the compiled template and diffs more readable.
    def format_lines_for_cloudformation(source)
      source.flat_map do |lines|
        lines = lines.to_s if lines.is_a?(Symbol)
        next(lines) unless lines.is_a?(String)

        newlines = Array.new(lines.count("\n"), "\n")
        newlines = lines.split("\n").map { |line| "#{line}#{newlines.pop}" }
        newlines.insert(0, "\n") if lines.start_with?("\n")
        newlines
      end
    end
  end
end
