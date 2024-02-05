# frozen_string_literal: true

require 'erubis'
require 'json'

module StackMaster
  # This class is a modified version of `Erubis::Eruby`. It provides extra
  # helper methods to ease the dynamic creation of CloudFormation templates
  # with ERB. These helper methods are available within `<%= %>` expressions.
  class CloudFormationTemplateEruby < Erubis::Eruby
    # Adds the contents of an EC2 userdata script to the CloudFormation
    # template. Allows using the ERB `<%= %>` expressions within the user data
    # script to interpolate CloudFormation values.
    def user_data_file(filepath)
      JSON.pretty_generate({ 'Fn::Base64' => { 'Fn::Join' => ['', user_data_file_as_lines(filepath)] } })
    end

    # Evaluate the ERB template at the specified filepath and return the result
    # as an array of lines. Allows using ERB `<%= %>` expressions to interpolate
    # CloudFormation objects into the result.
    def user_data_file_as_lines(filepath)
      StackMaster::CloudFormationInterpolatingEruby.evaluate_file(filepath, self)
    end

    # Add the contents of another file into the CloudFormation template as a
    # string. ERB `<%= %>` expressions within the referenced file are not
    # evaluated.
    def include_file(filepath)
      JSON.pretty_generate(File.read(filepath))
    end
  end
end
