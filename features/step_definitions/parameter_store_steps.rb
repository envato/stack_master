Given(/^(?:a|the) SSM parameter(?: named)? "([^"]*)" with value "([^"]*)" in region "([^"]*)"$/) do |parameter_name, parameter_value, parameter_region|
  File.open("/tmp/humpy-log", 'a') { |file| file.write("In Here name: #{parameter_name} value: #{parameter_value} \n") }
  Aws.config[:ssm] = {
    stub_responses: {
      get_parameter: {
        parameter: {
          name: parameter_name,
          value: parameter_value,
          type: "SecureString",
          version: 1
        }
      }
    }
  }
end
