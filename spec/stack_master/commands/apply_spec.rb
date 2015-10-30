RSpec.describe StackMaster::Commands::Apply do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:config) { double(find_stack: stack_definition) }
  let(:notification_arn) { 'test_arn' }
  let(:stack_definition) { StackMaster::Config::StackDefinition.new() }
  let(:proposed_stack) { StackMaster::Stack.new(template_body: '{}', tags: { 'environment' => 'production' } , parameters: { 'param_1' => 'hello' }, notification_arns: [notification_arn] ) }

  before do
    allow(StackMaster::Stack).to receive(:find).with(region, stack_name).and_return(stack)
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(cf).to receive(:update_stack)
    allow(cf).to receive(:create_stack)
    allow(StackMaster::StackDiffer).to receive(:perform).with(proposed_stack, stack)
    allow(STDOUT).to receive(:print)
    allow(STDIN).to receive(:getch).and_return('y')
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
  end

  def apply
    StackMaster::Commands::Apply.perform(config, region, stack_name)
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
        notification_arns: [notification_arn]
      )
    end

    it 'streams events' do
      apply
      expect(StackMaster::StackEvents::Streamer).to have_received(:stream).with(stack_name, region, io: STDOUT)
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
        notification_arns: [notification_arn]
      )
    end

    it 'streams events' do
      apply
      expect(StackMaster::StackEvents::Streamer).to have_received(:stream).with(stack_name, region, io: STDOUT)
    end
  end
end
