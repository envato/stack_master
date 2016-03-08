RSpec.describe StackMaster::Commands::Status do
  subject(:status) { described_class.new(config, false) }
  let(:config) { instance_double(StackMaster::Config, stacks: stacks) }
  let(:stacks) { [stack_definition_1, stack_definition_2] }
  let(:stack_definition_1) { double(:stack_definition_1, region: 'us-east-1', stack_name: 'stack1') }
  let(:stack_definition_2) { double(:stack_definition_2, region: 'us-east-1', stack_name: 'stack2', stack_status: 'CREATE_COMPLETE') }
  let(:cf) { Aws::CloudFormation::Client.new(region: 'us-east-1') }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).with(region: 'us-east-1').and_return cf
  end

  context "#perform" do
    before do
      allow(StackMaster::Stack).to receive(:find).and_return stack1, stack2
      allow(StackMaster::Stack).to receive(:generate).and_return proposed_stack1, proposed_stack2
    end

    context "some parameters are different" do
      let(:stack1) { double(:stack1, template_hash: {}, parameters_with_defaults: {a: 1}, stack_status: 'UPDATE_COMPLETE') }
      let(:stack2) { double(:stack2, template_hash: {}, parameters_with_defaults: {a: 2}, stack_status: 'CREATE_COMPLETE') }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", parameters_with_defaults: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", parameters_with_defaults: {a: 1}) }

      it "returns the status of call stacks" do
        out = "REGION    | STACK_NAME | STACK_STATUS    | DIFFERENT\n----------|------------|-----------------|----------\nus-east-1 | stack1     | UPDATE_COMPLETE | No       \nus-east-1 | stack2     | CREATE_COMPLETE | Yes      \n * No echo parameters can't be diffed\n"
        expect { status.perform }.to output(out).to_stdout
      end
    end

    context "some templates are different" do
      let(:stack1) { double(:stack1, template_hash: {foo: 'bar'}, parameters_with_defaults: {a: 1}, stack_status: 'UPDATE_COMPLETE') }
      let(:stack2) { double(:stack2, template_hash: {}, parameters_with_defaults: {a: 1}, stack_status: 'CREATE_COMPLETE') }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", parameters_with_defaults: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", parameters_with_defaults: {a: 1}) }

      it "returns the status of call stacks" do
        out = "REGION    | STACK_NAME | STACK_STATUS    | DIFFERENT\n----------|------------|-----------------|----------\nus-east-1 | stack1     | UPDATE_COMPLETE | Yes      \nus-east-1 | stack2     | CREATE_COMPLETE | No       \n * No echo parameters can't be diffed\n"
        expect { status.perform }.to output(out).to_stdout
      end
    end
  end

  context "handles AWS throttling" do
    let(:throttle_exception)  { Aws::CloudFormation::Errors::Throttling.new(double(), "Rate exceeded.") }
    let(:stack1) { double(:stack1, template_hash: {}, parameters_with_defaults: {a: 1}, stack_status: 'UPDATE_COMPLETE') }
    let(:stack2) { double(:stack2, template_hash: {}, parameters_with_defaults: {a: 2}, stack_status: 'CREATE_COMPLETE') }
    let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", parameters_with_defaults: {a: 1}) }
    let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", parameters_with_defaults: {a: 1}) }

    it "doubles the sleep time across calls" do
      call_count = 0
      expect(cf).to receive(:describe_stacks).at_least(1).times do 
        call_count += 1
        call_count <= 3 ? raise(throttle_exception) : double(stacks: double(first: nil))
      end
      expect(StackMaster.cloud_formation_driver).to receive(:sleep).with(1).ordered
      expect(StackMaster.cloud_formation_driver).to receive(:sleep).with(2).ordered
      expect(StackMaster.cloud_formation_driver).to receive(:sleep).with(4).ordered
      expect { status.perform }.to_not raise_exception
    end
  end
end
