RSpec.describe "drift command", type: :aruba do
  let(:cfn) { Aws::CloudFormation::Client.new(stub_responses: true) }
  let(:expected_properties) { '{"CidrIp":"1.2.3.4/0","FromPort":80,"IpProtocol":"tcp","ToPort":80}' }
  let(:actual_properties) { '{"CidrIp":"5.6.7.8/0","FromPort":80,"IpProtocol":"tcp","ToPort":80}' }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cfn)
    write_file("stack_master.yml", <<~FILE)
      stacks:
        us-east-1:
          myapp-web:
            template: myapp_web.rb
    FILE
  end

  context 'when drifted' do
    before do
      stub_drift_detection(stack_drift_status: "DRIFTED")
      stub_stack_resource_drift(
        stack_name: "myapp-web",
        stack_resource_drifts: [
          stack_id: "1",
          timestamp: Time.now,
          stack_resource_drift_status: "MODIFIED",
          resource_type: "AWS::EC2::SecurityGroup",
          logical_resource_id: "SecurityGroup",
          physical_resource_id: "sg-123456",
          expected_properties: expected_properties,
          actual_properties: actual_properties,
          property_differences: [
            {
              difference_type: 'ADD',
              property_path: '/SecurityGroupIngress/2',
              expected_value: "",
              actual_value: "",
            }
          ]
        ]
      )
      run_command_and_stop("stack_master drift us-east-1 myapp-web --trace", fail_on_error: false)
    end

    it "exits unsuccessfully" do
      expect(last_command_stopped).not_to be_successfully_executed
    end

    it 'outputs stack drift information' do
      [
        "Drift Status: DRIFTED",
        "MODIFIED AWS::EC2::SecurityGroup SecurityGroup sg-123456",
        "- ADD /SecurityGroupIngress/2",
        '\-  "CidrIp": "1.2.3.4/0",',
        '\+  "CidrIp": "5.6.7.8/0",'
      ].each do |line|
        expect(last_command_stopped).to have_output an_output_string_matching(line)
      end
    end
  end

  context 'when not drifted' do
    before do
      stub_drift_detection(stack_drift_status: "IN_SYNC")
      stub_stack_resource_drift(
        stack_name: "myapp-web",
        stack_resource_drifts: []
      )
      run_command_and_stop("stack_master drift us-east-1 myapp-web --trace", fail_on_error: false)
    end

    it 'exits successfully' do
      expect(last_command_stopped).to be_successfully_executed
    end

    it 'outputs stack drift information' do
      [
        "Drift Status: IN_SYNC"
      ].each do |line|
        expect(last_command_stopped).to have_output an_output_string_matching(line)
      end
    end
  end
end
