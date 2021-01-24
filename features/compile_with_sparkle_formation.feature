Feature: Compile command with a SparkleFormation template

  Scenario: Run compile stack on SparkleFormation template
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_vpc.yml" with:
      """
      KeyName: my-key
      compile_time_parameters:
        cidr_block: 10.200.0.0/16
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc,
                           compile_time_parameters: { cidr_block: { type: :string }}) do
        description "Test template"

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

        outputs.vpc_id do
          description 'A VPC ID'
          value ref!(:vpc)
        end
      end
      """
    When I run `stack_master compile us-east-1 myapp-vpc`
    Then the output should contain all of these lines:
      | Executing compile on myapp-vpc in us-east-1 |
      | {                                           |
      |   "Description": "Test template",           |
      |   "Parameters": {                           |
      |     "KeyName": {                            |
      |       "Description": "Key name",            |
      |       "Type": "String"                      |
      |     }                                       |
      |   },                                        |
      |   "Resources": {                            |
      |     "Vpc": {                                |
      |       "Type": "AWS::EC2::VPC",              |
      |       "Properties": {                       |
      |         "CidrBlock": "10.200.0.0/16"        |
      |       }                                     |
      |     }                                       |
      |   },                                        |
      |   "Outputs": {                              |
      |     "VpcId": {                              |
      |       "Description": "A VPC ID",            |
      |       "Value": {                            |
      |         "Ref": "Vpc"                        |
      |       }                                     |
      |     }                                       |
      |   }                                         |
      | }                                           |
    And the exit status should be 0
