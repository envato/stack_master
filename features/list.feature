Feature: List command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          stack1:
            template: stack1.json
          stack2:
            template: stack2.json
          stack3:
            template: stack3.json
      """

  Scenario: Run list command and get a list of stacks
    When I run `stack_master list` interactively
    Then the output should contain all of these lines:
      | REGION    | STACK_NAME|
      | ----------|---------- |
      | us-east-1 | stack1    |
      | us-east-1 | stack2    |
      | us-east-1 | stack3    |

    And the exit status should be 0

  Scenario: Run list command and get machine-readable list of stacks
    When I run `stack_master list --machine-readable` interactively
    Then the output should contain all of these lines:
      |us-east-1 stack1|
      |us-east-1 stack2|
      |us-east-1 stack3|

    And the exit status should be 0
