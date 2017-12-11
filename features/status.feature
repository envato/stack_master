Feature: Status command

  Background:
    Given a file named "stack_master.yml" with:
      """
      environments:
        prod:
          region: us-east-1
          stacks:
            stack1:
              template: stack1.json
            stack2:
              template: stack2.json
            stack3:
              template: stack3.json
      """
    And a directory named "parameters"
    And a file named "parameters/stack1.yml" with:
      """
      KeyName: my-key
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
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {},
  "Mappings": {},
  "Resources": {
    "MoarQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "1"
      }
    }
  },
  "Outputs": {}
}
      """
    And a file named "templates/stack3.json" with:
      """
{
}
      """

  Scenario: Run status command and get a list of stack statuii
    Given I stub the following stacks:
      | stack_id | stack_name  | parameters     | region    | stack_status    |
      |        1 | prod-stack1 | KeyName=my-key | us-east-1 | CREATE_COMPLETE |
      |        2 | prod-stack2 |                | us-east-1 | UPDATE_COMPLETE |
    And I stub a template for the stack "prod-stack1":
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
        "VisibilityTimeout" : "7"
      }
    }
  },
  "Outputs": {}
}
      """
    And I stub a template for the stack "prod-stack2":
      """
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {},
  "Mappings": {},
  "Resources": {
    "MoarQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "1"
      }
    }
  },
  "Outputs": {}
}
      """

    When I run `stack_master status --trace`
    And the output should contain all of these lines:
      | ENVIRONMENT \| STACK_NAME \| REGION    \| STACK_STATUS    \| DIFFERENT |
      | ------------\|------------\|-----------\|-----------------\|---------- |
      | prod        \| stack1     \| us-east-1 \| CREATE_COMPLETE \| Yes       |
      | prod        \| stack2     \| us-east-1 \| UPDATE_COMPLETE \| No        |
      | prod        \| stack3     \| us-east-1 \|                 \| Yes       |
      
    Then the exit status should be 0

