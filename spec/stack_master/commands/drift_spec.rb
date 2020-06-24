RSpec.describe StackMaster::Commands::Drift do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:config) { instance_double(StackMaster::Config) }
  let(:options) { Commander::Command::Options.new }
  let(:stack_definition) { instance_double(StackMaster::StackDefinition, stack_name: 'myapp', region: 'us-east-1') }

  subject(:drift) { described_class.new(config, stack_definition, options) }
  let(:stack_drift_detection_id) { 123 }
  let(:detect_stack_drift_response) { Aws::CloudFormation::Types::DetectStackDriftOutput.new(stack_drift_detection_id: stack_drift_detection_id) }
  let(:stack_drift_status) { "IN_SYNC" }
  let(:describe_stack_drift_detection_status_response) {
    Aws::CloudFormation::Types::DescribeStackDriftDetectionStatusOutput.new(stack_drift_detection_id: stack_drift_detection_id,
                                                                            stack_drift_status: stack_drift_status,
                                                                            detection_status: "DETECTION_COMPLETE")
  }
  let(:describe_stack_resource_drifts_response) { Aws::CloudFormation::Types::DescribeStackResourceDriftsOutput.new(stack_resource_drifts: stack_resource_drifts) }
  let(:property_difference) { Aws::CloudFormation::Types::PropertyDifference.new(
                                                           difference_type: 'ADD',
                                                           property_path: '/SecurityGroupIngress/2'
                                                         ) }
  let(:stack_resource_drifts) { [
    Aws::CloudFormation::Types::StackResourceDrift.new(stack_resource_drift_status: "IN_SYNC",
                                                       resource_type: "AWS::EC2::SecurityGroup",
                                                       logical_resource_id: "SecurityGroup",
                                                       physical_resource_id: "sg-123456",
                                                       property_differences: [
                                                         property_difference
                                                       ])
  ] }

  before do
    allow(StackMaster).to receive(:cloud_formation_driver).and_return(cf)
    allow(cf).to receive(:detect_stack_drift).and_return(detect_stack_drift_response)

    allow(cf).to receive(:describe_stack_drift_detection_status).and_return(describe_stack_drift_detection_status_response)
    allow(cf).to receive(:describe_stack_resource_drifts).and_return(describe_stack_resource_drifts_response)
    stub_const('StackMaster::Commands::Drift::SLEEP_SECONDS', 0)
  end

  context "when the stack hasn't drifted" do
    it 'outputs drift status' do
      expect { drift.perform }.to output(/Drift Status: IN_SYNC/).to_stdout
    end

    it 'exits with success' do
      drift.perform
      expect(drift).to be_success
    end
  end

  context 'when the stack has drifted' do
    let(:stack_drift_status) { 'DRIFTED' }
    let(:expected_properties) { '{"CidrIp":"1.2.3.4/0","FromPort":80,"IpProtocol":"tcp","ToPort":80}' }
    let(:actual_properties) { '{"CidrIp":"5.6.7.8/0","FromPort":80,"IpProtocol":"tcp","ToPort":80}' }
    let(:stack_resource_drifts) { [
      Aws::CloudFormation::Types::StackResourceDrift.new(stack_resource_drift_status: "DELETED",
                                                         resource_type: "AWS::EC2::SecurityGroup",
                                                         logical_resource_id: "SecurityGroup1",
                                                         physical_resource_id: "sg-123456",
                                                         property_differences: [property_difference]),
      Aws::CloudFormation::Types::StackResourceDrift.new(stack_resource_drift_status: "MODIFIED",
                                                         resource_type: "AWS::EC2::SecurityGroup",
                                                         logical_resource_id: "SecurityGroup2",
                                                         physical_resource_id: "sg-789012",
                                                         expected_properties: expected_properties,
                                                         actual_properties: actual_properties,
                                                         property_differences: [property_difference]),
      Aws::CloudFormation::Types::StackResourceDrift.new(stack_resource_drift_status: "IN_SYNC",
                                                         resource_type: "AWS::EC2::SecurityGroup",
                                                         logical_resource_id: "SecurityGroup3",
                                                         physical_resource_id: "sg-345678",
                                                         property_differences: [property_difference])
    ] }

    it 'outputs drift status' do
      expect { drift.perform }.to output(/Drift Status: DRIFTED/).to_stdout
    end

    it 'reports resource status', aggregate_failures: true do
      expect { drift.perform }.to output(/DELETED AWS::EC2::SecurityGroup SecurityGroup1 sg-123456/).to_stdout
      expect { drift.perform }.to output(/MODIFIED AWS::EC2::SecurityGroup SecurityGroup2 sg-789012/).to_stdout
      expect { drift.perform }.to output(/IN_SYNC AWS::EC2::SecurityGroup SecurityGroup3 sg-345678/).to_stdout
    end

    it 'exits with failure' do
      drift.perform
      expect(drift).to_not be_success
    end
  end

  context "when stack drift detection doesn't complete" do
    before do
      describe_stack_drift_detection_status_response.detection_status = 'UNKNOWN'
      options.timeout = 0
    end

    it 'raises an error' do
      expect { drift.perform }.to raise_error(/Timeout waiting for stack drift detection/)
    end
  end
end
