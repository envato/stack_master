Feature: Apply command with allowed accounts

  Background:
    Given a file named "stack_master.yml" with:
      """
      stack_defaults:
        allowed_accounts:
          - '11111111'
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp.rb
          myapp_db:
            template: myapp.rb
            allowed_accounts: '22222222'
          myapp_web:
            template: myapp.rb
            allowed_accounts: []
          myapp_cache:
            template: myapp.rb
            allowed_accounts: my-account-alias
      """
    And a directory named "templates"
    And a file named "templates/myapp.rb" with:
      """
      SparkleFormation.new(:myapp) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')
      end
      """

  Scenario: Run apply with stack inheriting allowed accounts from stack defaults
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I use the account "11111111"
    And I run `stack_master apply us-east-1 myapp-vpc`
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run apply with stack overriding allowed accounts with its own list
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-db   | myapp-db            | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I use the account "11111111"
    And I run `stack_master apply us-east-1 myapp-db`
    And the output should contain all of these lines:
      | Account '11111111' is not an allowed account. Allowed accounts are ["22222222"].|
    Then the exit status should be 1

  Scenario: Run apply with stack overriding allowed accounts to allow all accounts
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I use the account "33333333"
    And I run `stack_master apply us-east-1 myapp-web`
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run apply with stack specifying allowed account alias
    Given I stub the following stack events:
      | stack_id | event_id | stack_name  | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-cache | myapp-cache         | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I use the account "44444444" with alias "my-account-alias"
    And I run `stack_master apply us-east-1 myapp-cache`
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-cache AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run apply with stack specifying disallowed account alias
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-db   | myapp-db            | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I use the account "11111111" with alias "an-account-alias"
    And I run `stack_master apply us-east-1 myapp-db`
    And the output should contain all of these lines:
      | Account '11111111' (an-account-alias) is not an allowed account. Allowed accounts are ["22222222"].|
    Then the exit status should be 1
