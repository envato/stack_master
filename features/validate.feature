Feature: Validate command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        stack1:
          template: stack1.json
      """
    And a directory named "parameters"
    And a file named "parameters/stack1.yml" with:
      """
      InstanceTypeParameter: my-type
      """
    And a directory named "templates"
    And a file named "templates/stack1.json" with:
      """
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {
    "InstanceTypeParameter" : { "Type" : "String" }
  },
  "Mappings": {},
  "Resources": {
    "MyAwesomeQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "1"
      }
    }
  },
  "Outputs": {}
}
      """

  Scenario: Validate successfully
    Given I stub CloudFormation validate calls to pass validation
    And I run `stack_master validate us-east-1 stack1`
    Then the output should contain "stack1: valid"

  Scenario: Validate unsuccessfully
    Given I stub CloudFormation validate calls to fail validation with message "Blah"
    And I run `stack_master validate us-east-1 stack1`
    Then the output should contain "stack1: invalid. Blah"
