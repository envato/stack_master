Feature: Delete command

  Scenario: Run a delete command on a stack that exists
    Given I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      |        1 |        1 | myapp-vpc  | myapp-vpc           | DELETE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master delete us-east-1 myapp-vpc --trace`
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack DELETE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run a delete command on a stack that exists quietly
    Given I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      |        1 |        1 | myapp-vpc  | myapp-vpc           | DELETE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master delete us-east-1 myapp-vpc -q`
    And the output should not match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack DELETE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run a delete command on a stack that does not exists
    When I run `stack_master delete us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack does not exist |
    Then the exit status should be 0

  Scenario: Answer no when asked to delete stack
    Given I will answer prompts with "n"
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 | 
    When I run `stack_master delete us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack update aborted |
    Then the exit status should be 0

