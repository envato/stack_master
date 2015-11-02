Feature: Outputs command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')
        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block '10.200.0.0/16'
          end
        end
      end
      """
    And I set the environment variables to:
      | variable | value |
      | STUB_AWS | true  |
      | ANSWER   | y     |

  Scenario: Output stack resources
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    | outputs          |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 | VpcId=vpc-123456 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
      }
      """
    When I run `stack_master outputs us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | VpcId      |
      | vpc-123456 |

  Scenario: Fails when the stack doesn't exist
    When I run `stack_master outputs us-east-1 myapp-vpc --trace`
    And the output should not contain all of these lines:
      | VpcId      |
      | vpc-123456 |
    And the output should contain "Stack doesn't exist"
