RSpec.describe StackMaster::Commands::Apply do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:config) { double(find_stack: stack_definition) }
  let(:notification_arn) { 'test_arn' }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: region, stack_name: stack_name) }
  let(:template_body) { '{}' }
  let(:proposed_stack) { StackMaster::Stack.new(template_body: template_body, tags: { 'environment' => 'production' } , parameters: { 'param_1' => 'hello' }, notification_arns: [notification_arn], stack_policy_body: stack_policy_body ) }
  let(:stack_policy_body) { '{}' }

  before do
    allow(StackMaster::Stack).to receive(:find).with(region, stack_name).and_return(stack)
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
    allow(config).to receive(:stack_defaults).and_return({})
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(cf).to receive(:update_stack)
    allow(cf).to receive(:create_stack)
    allow(StackMaster::StackDiffer).to receive(:new).with(proposed_stack, stack).and_return double.as_null_object
    allow(STDOUT).to receive(:print)
    allow(STDIN).to receive(:getch).and_return('y')
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
  end

  def apply
    StackMaster::Commands::Apply.perform(config, stack_definition)
  end

  context 'the stack exist' do
    let(:stack) { StackMaster::Stack.new(stack_id: '1') }

    it 'calls the update stack API method' do
      apply
      expect(cf).to have_received(:update_stack).with(
        stack_name: stack_name,
        template_body: proposed_stack.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        capabilities: ['CAPABILITY_IAM'],
        notification_arns: [notification_arn],
        stack_policy_body: stack_policy_body
      )
    end

    it 'streams events' do
      Timecop.freeze(Time.local(1990)) do
        apply
        expect(StackMaster::StackEvents::Streamer).to have_received(:stream).with(stack_name, region, io: STDOUT, from: Time.now)
      end
    end

    context 'when a CF error occurs' do
      before do
        allow(cf).to receive(:update_stack).with(anything).and_raise(Aws::CloudFormation::Errors::ServiceError.new('a', 'the message'))
      end

      it 'outputs the message' do
        expect { apply }.to output(/the message/).to_stdout
      end
    end
  end

  context 'the stack does not exist' do
    let(:stack) { nil }

    it 'calls the create stack API method' do
      apply
      expect(cf).to have_received(:create_stack).with(
        stack_name: stack_name,
        template_body: proposed_stack.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        tags: [
          {
            key: 'environment',
            value: 'production'
          }],
        capabilities: ['CAPABILITY_IAM'],
        notification_arns: [notification_arn],
        stack_policy_body: stack_policy_body
      )
    end

    context 'the stack is too large' do
      let(:big_string) { 'x' * 60000 }
      let(:template_body) do
        "{\"a\":\"#{big_string}\"}"
      end
      it 'exits with a message' do
        expect { apply }.to output(/The \(space compressed\) stack is larger than the limit set by AWS/).to_stdout
      end
    end

    it 'streams events' do
      Timecop.freeze(Time.local(1990)) do
        apply
        expect(StackMaster::StackEvents::Streamer).to have_received(:stream).with(stack_name, region, io: STDOUT, from: Time.now)
      end
    end
  end
end
