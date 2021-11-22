Feature: Validate command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          stack0:
            template: stack1.json
          stack1:
            template: stack1.json
          stack2:
            template: stack2.json
      """
    And a directory named "parameters"
    And a file named "parameters/stack1.yml" with:
      """
      InstanceTypeParameter: my-type
      """
    And a file named "parameters/stack0.yml" with:
      """
      InstanceTypeParameter:
        stack_output: nonexistantstack/output
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
    And a file named "templates/stack2.json" with:
      """
{}
      """

  Scenario: Validate successfully
    Given I stub CloudFormation validate calls to pass validation
    And I run `stack_master validate us-east-1 stack1`
    Then the output should contain "stack1: valid"
    And the exit status should be 0

  Scenario: Invalid template
    Given I stub CloudFormation validate calls to fail validation with message "Blah"
    And I run `stack_master validate us-east-1 stack1`
    Then the output should contain "stack1: invalid. Blah"
    And the exit status should be 1

  Scenario: One validate unsuccessfully, one successful
    Given I stub CloudFormation validate calls to fail validation with message "Blah"
    And I stub CloudFormation validate calls to pass validation
    And I run `stack_master validate us-east-1 stack1 us-east-1 stack2`
    Then the output should contain "stack1: invalid. Blah"
    And the exit status should be 1

  Scenario: Missing parameter from resolver
    Given I skip this test
    And I stub CloudFormation validate calls to fail validation with message "Blah"
    And I stub CloudFormation validate calls to pass validation
    And I run `stack_master validate`
    Then the output should contain all of these lines:
      | stack0: error: Unable to resolve parameter "output" value causing error: Stack with id nonexistantstack does not exist. Use --trace to view backtrace |
      | stack1: invalid. Blah                                                                                                                                 |
      | stack2: valid                                                                                                                                         |
    And the exit status should be 1
