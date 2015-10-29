Feature: init project

  Scenario: Run init
    When I run `stack_master init`
    # TODO flesh this out
    Then the exit status should be 0
