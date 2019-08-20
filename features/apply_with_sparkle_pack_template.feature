Feature: Apply command with compile time parameters

  Background:
    Given a file named "stack_master.yml" with:
    """
    stacks:
      us-east-1:
        sparkle_pack_test:
          template: template_with_dynamic_from_pack
          compiler: sparkle_formation
          compiler_options:
            sparkle_pack_template: true
            sparkle_packs:
              - my_sparkle_pack
    """
    And a directory named "templates"

  Scenario: Run apply and create a new stack
    When I run `stack_master apply us-east-1 sparkle_pack_test -q --trace`
    Then the output should contain all of these lines:
      | +{                     |
      | +  "Outputs": {        |
      | +    "Foo": {          |
      | +      "Value": "bar"  |
      | +    }                 |
      | +  }                   |
      | +}                     |
    And the exit status should be 0

  Scenario: An unknown compiler
    Given a file named "stack_master.yml" with:
    """
    stacks:
      us-east-1:
        sparkle_pack_test:
          template: template_with_dynamic_from_pack
          compiler: foobar
    """
    When I run `stack_master apply us-east-1 sparkle_pack_test -q --trace`
    Then the output should contain all of these lines:
      | Unknown compiler "foobar" |
