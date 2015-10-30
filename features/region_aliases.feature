Feature: Region aliases

  Background:
    Given a file named "stack_master.yml" with:
      """
      region_aliases:
        staging: ap-southeast-2
        production: us_east_1
      stacks:
        staging:
          myapp_vpc:
            template: myapp_vpc.rb
        production:
          myapp_vpc:
            template: myapp_vpc.rb
      """
    And a directory named "templates"
    And a directory named "parameters"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')

        parameters.key_name do
          description 'Key name'
          type 'String'
        end

        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block '10.200.0.0/16'
          end
        end

        outputs do
          vpc_id do
            description 'A VPC ID'
            value ref!(:vpc)
          end
        end
      end
      """
    And a file named "parameters/myapp_vpc.yml" with:
      """
      key_name: my-key
      """
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I set the environment variables to:
      | variable | value |
      | STUB_AWS | true  |
      | ANSWER   | y     |

  Scenario: Create a stack using region aliases
    When I run `stack_master apply ap-southeast-2 myapp-vpc --trace` interactively
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "Vpc": {                                                                  |
      | Parameters diff:                                                               |
      | "KeyName": "my-key"                                                            |
      | 2020-10-29 00:00:00 +1100 myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE |
    Then the exit status should be 0
