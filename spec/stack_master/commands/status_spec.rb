RSpec.describe StackMaster::Commands::Status do
  subject(:status) { described_class.new(config) }
  let(:config) { instance_double(StackMaster::Config, stack_definitions: stack_definitions) }
  let(:stack_definitions) { instance_double(StackMaster::Config::StackDefinitions, stacks: stacks) }
  let(:stacks) { [stack_definition_1, stack_definition_2] }
  let(:stack_definition_1) { double(:stack_definition_1, region: 'us-east-1', stack_name: 'stack1') }
  let(:stack_definition_2) { double(:stack_definition_2, region: 'us-east-1', stack_name: 'stack2') }
  let(:cf) { Aws::CloudFormation::Client.new(region: 'us-east-1') }
  let(:events) do
    [
      { event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: Time.now, resource_status: 'UPDATE_COMPLETE'},
    ]
  end

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).with(region: 'us-east-1').and_return cf
    cf.stub_responses(:describe_stack_events, stack_events: events)
    allow(StackMaster::Stack).to receive(:find).and_return stack1, stack2
    allow(StackMaster::Stack).to receive(:generate).and_return proposed_stack1, proposed_stack2
  end

  context "#perform" do
    context "some parameters are different" do
      let(:stack1) { double(:stack1, template_hash: {}, parameters: {a: 1}) }
      let(:stack2) { double(:stack2, template_hash: {}, parameters: {a: 2}) }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", parameters: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", parameters: {a: 1}) }
      it "returns the status of call stacks" do
        out = "REGION    | STACK_NAME | STACK_STATUS    | DIFFERENT\n----------|------------|-----------------|----------\nus-east-1 | stack1     | UPDATE_COMPLETE | No       \nus-east-1 | stack2     | UPDATE_COMPLETE | Yes      \n"
        expect { status.perform }.to output(out).to_stdout
      end
    end

    context "some templates are different" do
      let(:stack1) { double(:stack1, template_hash: {foo: 'bar'}, parameters: {a: 1}) }
      let(:stack2) { double(:stack2, template_hash: {}, parameters: {a: 1}) }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", parameters: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", parameters: {a: 1}) }
      it "returns the status of call stacks" do
        out = "REGION    | STACK_NAME | STACK_STATUS    | DIFFERENT\n----------|------------|-----------------|----------\nus-east-1 | stack1     | UPDATE_COMPLETE | Yes      \nus-east-1 | stack2     | UPDATE_COMPLETE | No       \n"
        expect { status.perform }.to output(out).to_stdout
      end
    end
  end
end
