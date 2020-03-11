Feature: Check the StackMaster version
  Scenario: Use the --version option
    When I run `stack_master --version`
    Then the exit status should be 0
