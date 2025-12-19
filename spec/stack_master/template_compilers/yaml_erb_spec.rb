# frozen_string_literal: true

RSpec.describe StackMaster::TemplateCompilers::YamlErb do
  before(:all) { described_class.require_dependencies }

  describe '.compile' do
    subject(:compile) do
      described_class.compile(
        stack_definition.template_dir,
        stack_definition.template,
        compile_time_parameters
      )
    end

    context 'a YAML template using a loop over compile time parameters' do
      let(:stack_definition) do
        StackMaster::StackDefinition.new(
          template_dir: 'spec/fixtures/templates/erb',
          template: 'compile_time_parameters_loop.yml.erb'
        )
      end

      let(:compile_time_parameters) do
        { 'SubnetCidrs' => ['10.0.0.0/28:ap-southeast-2', '10.0.2.0/28:ap-southeast-1'] }
      end

      it 'renders the expected output' do
        expect(compile).to eq(<<~YAML)
          ---
          Description: "A test case for generating subnet resources in a loop"
          Parameters:
            VpcCidr:
              type: String

          Resources:
            Vpc:
              Type: AWS::EC2::VPC
              Properties:
                CidrBlock: !Ref VpcCidr
            SubnetPrivate0:
              Type: AWS::EC2::Subnet
              Properties:
                VpcId: !Ref Vpc
                CidrBlock: 10.0.0.0/28
                AvailabilityZone: ap-southeast-2
            SubnetPrivate1:
              Type: AWS::EC2::Subnet
              Properties:
                VpcId: !Ref Vpc
                CidrBlock: 10.0.2.0/28
                AvailabilityZone: ap-southeast-1
        YAML
      end
    end

    context 'a YAML template using loading a userdata script from an external file' do
      let(:stack_definition) do
        StackMaster::StackDefinition.new(
          template_dir: 'spec/fixtures/templates/erb',
          template: 'user_data.yml.erb'
        )
      end

      let(:compile_time_parameters) { {} }

      it 'renders the expected output' do
        expect(compile).to eq(<<~YAML)
          Description: A test case for storing the userdata script in a dedicated file

          Resources:
            LaunchConfig:
              Type: 'AWS::AutoScaling::LaunchConfiguration'
              Properties:
                UserData: {
            "Fn::Base64": {
              "Fn::Join": [
                "",
                [
                  "#!/bin/bash\\n",
                  "\\n",
                  "echo 'Hello, World!'\\n",
                  "REGION=",
                  {
                    "Ref": "AWS::Region"
                  },
                  "\\n",
                  "echo $REGION\\n"
                ]
              ]
            }
          }
        YAML
      end
    end
  end
end
