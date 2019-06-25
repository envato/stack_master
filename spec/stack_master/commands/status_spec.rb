RSpec.describe StackMaster::Commands::Status do
  subject(:status) { described_class.new(config, false) }
  let(:config) { instance_double(StackMaster::Config, stacks: stacks) }
  let(:stacks) { [stack_definition_1, stack_definition_2] }
  let(:stack_definition_1) { double(:stack_definition_1, region: 'us-east-1', stack_name: 'stack1', allowed_accounts: []) }
  let(:stack_definition_2) { double(:stack_definition_2, region: 'us-east-1', stack_name: 'stack2', stack_status: 'CREATE_COMPLETE', allowed_accounts: []) }
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
      let(:stack1) { double(:stack1, template_body: '{}', template_hash: {}, template_format: :json, parameters_with_defaults: {a: 1}, stack_status: 'UPDATE_COMPLETE') }
      let(:stack2) { double(:stack2, template_body: '{}', template_hash: {}, template_format: :json, parameters_with_defaults: {a: 2}, stack_status: 'CREATE_COMPLETE') }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", template_format: :json, parameters_with_defaults: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", template_format: :json, parameters_with_defaults: {a: 1}) }

      it "returns the status of call stacks" do
        out = "REGION    | STACK_NAME | STACK_STATUS    | DIFFERENT\n----------|------------|-----------------|----------\nus-east-1 | stack1     | UPDATE_COMPLETE | No       \nus-east-1 | stack2     | CREATE_COMPLETE | Yes      \n * No echo parameters can't be diffed\n"
        expect { status.perform }.to output(out).to_stdout
      end
    end

    context "some templates are different" do
      let(:stack1) { double(:stack1, template_body: '{"foo": "bar"}', template_hash: {foo: 'bar'}, template_format: :json, parameters_with_defaults: {a: 1}, stack_status: 'UPDATE_COMPLETE') }
      let(:stack2) { double(:stack2, template_body: '{}', template_hash: {}, template_format: :json, parameters_with_defaults: {a: 1}, stack_status: 'CREATE_COMPLETE') }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", template_format: :json, parameters_with_defaults: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", template_format: :json, parameters_with_defaults: {a: 1}) }

      it "returns the status of call stacks" do
        out = "REGION    | STACK_NAME | STACK_STATUS    | DIFFERENT\n----------|------------|-----------------|----------\nus-east-1 | stack1     | UPDATE_COMPLETE | Yes      \nus-east-1 | stack2     | CREATE_COMPLETE | No       \n * No echo parameters can't be diffed\n"
        expect { status.perform }.to output(out).to_stdout
      end
    end

    context 'when identity account is not allowed' do
      let(:sts) { Aws::STS::Client.new(stub_responses: true) }
      let(:stack_definition_1) { double(:stack_definition_1, region: 'us-east-1', stack_name: 'stack1', allowed_accounts: ['not-account-id']) }
      let(:stack1) { double(:stack1, template_body: '{"foo": "bar"}', template_hash: {foo: 'bar'}, template_format: :json, parameters_with_defaults: {a: 1}, stack_status: 'UPDATE_COMPLETE') }
      let(:stack2) { double(:stack2, template_body: '{}', template_hash: {}, template_format: :json, parameters_with_defaults: {a: 1}, stack_status: 'CREATE_COMPLETE') }
      let(:proposed_stack1) { double(:proposed_stack1, template_body: "{}", template_format: :json, parameters_with_defaults: {a: 1}) }
      let(:proposed_stack2) { double(:proposed_stack2, template_body: "{}", template_format: :json, parameters_with_defaults: {a: 1}) }

      before do
        allow(Aws::STS::Client).to receive(:new).and_return(sts)
        sts.stub_responses(:get_caller_identity, {
          account: 'account-id',
          arn: 'an-arn',
          user_id: 'a-user-id'
        })
      end

      it 'sets stack status and different fields accordingly' do
        out = <<~OUTPUT
          REGION    | STACK_NAME | STACK_STATUS       | DIFFERENT
          ----------|------------|--------------------|----------
          us-east-1 | stack1     | Disallowed account | N/A      
          us-east-1 | stack2     | UPDATE_COMPLETE    | Yes      
           * No echo parameters can't be diffed
        OUTPUT
        expect { status.perform }.to output(out).to_stdout
      end
    end
  end

end
