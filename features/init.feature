Feature: init project

  Scenario: Run init
    When I run `stack_master init us-east-1 my-app`
    Then the exit status should be 0
