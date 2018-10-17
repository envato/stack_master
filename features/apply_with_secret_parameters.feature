Feature: Apply command with parameter_store parameter

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us-east-2:
          vpc:
            template: vpc.rb
            secret_file: production.yml.gpg
      """
    And a directory named "parameters"
    And a file named "parameters/vpc.yml" with:
      """
      vpc_cidr:
        secrets: "cucumber-test-vpc-cidr"
      """
    And a directory named "secrets"
    And a file named "secrets/production.yml.gpg" with ""
    And a directory named "templates"
    And a file named "templates/vpc.rb" with:
      """
      SparkleFormation.new(:vpc) do

        parameters.vpc_cidr do
          type 'String'
        end

        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block ref!(:vpc_cidr)
          end
        end

      end
      """

  Scenario: Run apply and create a new stack
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | vpc        | Vpc                 | CREATE_COMPLETE | AWS::EC2::VPC              | 2020-10-29 00:00:00 |
      | 1        | 1        | vpc        | vpc                 | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub DotGPG calls to return a secret for "cucumber-test-vpc-cidr"
    When I run `stack_master apply -y us-east-2 vpc`
    Then the stderr should contain:
    """
    [DEPRECATION WARNING] The GPG Parameter Resolver is being deprecated in favour of the Parameter Store and 1Password resolvers.
    Support for GPG encrypted secrets will be removed in StackMaster 2.0
    """
    And the exit status should be 0
