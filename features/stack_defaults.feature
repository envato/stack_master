Feature: Stack defaults

  Background:
    Given a file named "stack_master.yml" with:
      """
      stack_defaults:
        tags:
          application: my-awesome-blog
      region_defaults:
        ap_southeast_2:
          notification_arns:
          - test_arn_1
          secret_file: staging.yml.gpg
          tags:
            environment: staging
          stack_policy_file: my_policy.json
        us_east_1:
          notification_arns:
          - test_arn_2
          secret_file: production.yml.gpg
          tags:
            environment: production
      environments:
        prod:
          region: ap-southeast-2
          stacks:
            myapp_vpc:
              template: myapp_vpc.rb
              tags:
                role: network
              notification_arns:
                - test_arn_3
        stage:
          region: us-east-1
          stacks:
            myapp_vpc:
              template: myapp_vpc.rb
              tags:
                role: network
      """
    And a directory named "templates"
    And a directory named "policies"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')

        parameters.key_name do
          description 'Key name'
          type 'String'
          default 'blah'
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
    And a file named "policies/my_policy.json" with:
      """
      {my: 'policy'}
      """
    And I stub the following stack events:
      | stack_id | event_id | stack_name      | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | prod-myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | prod-myapp-vpc  | prod-myapp-vpc      | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |

  Scenario: Create a stack with inherited attributes
    When I run `stack_master apply prod myapp-vpc --trace`
    Then the stack "prod-myapp-vpc" should contain this notification ARN "test_arn_1"
    Then the stack "prod-myapp-vpc" should contain this notification ARN "test_arn_3"
    And the stack "prod-myapp-vpc" should have a policy with the following:
      """
      {my: 'policy'}
      """
