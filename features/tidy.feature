Feature: Tidy command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          stack1:
            template: stack1.json
          stack5:
            template: stack5.json
      """
    And a directory named "parameters"
    And an empty file named "parameters/stack1.yml"
    And an empty file named "parameters/stack4.yml"
    And a directory named "templates"
    And an empty file named "templates/stack1.json"
    And an empty file named "templates/stack2.rb"
    And a directory named "templates/dynamics"
    And an empty file named "templates/dynamics/my_dynamic.rb"

  Scenario: Tidy identifies extra & missing files
    Given I run `stack_master tidy --trace`
    Then the output should contain all of these lines:
      | Stack "stack5" in "us-east-1" missing template "templates/stack5.json" |
      | templates/stack2.rb: no stack found for this template |
      | parameters/stack4.yml: no stack found for this parameter file |
    And the output should not contain "stack1"
    And the exit status should be 0
