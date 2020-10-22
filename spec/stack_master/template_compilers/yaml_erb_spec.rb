# frozen_string_literal: true

RSpec.describe StackMaster::TemplateCompilers::YamlErb do
  before(:all) { described_class.require_dependencies }

  describe '.compile' do
    let(:compile_time_parameters) { { 'SubnetCidrs' => ['10.0.0.0/28:ap-southeast-2', '10.0.2.0/28:ap-southeast-1'] } }

    def compile
      described_class.compile(stack_definition.template_dir, stack_definition.template, compile_time_parameters)
    end

    context 'a YAML template using a loop over compile time parameters' do
      let(:stack_definition) { StackMaster::StackDefinition.new(template_dir: 'spec/fixtures/templates/erb',
                                                                template: 'compile_time_parameters_loop.yml.erb') }

      it 'renders the expected output' do
        expect(compile).to eq <<~EOEXPECTED
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
          EOEXPECTED
      end
    end
  end
end
