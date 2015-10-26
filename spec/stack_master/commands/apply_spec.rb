RSpec.describe StackMaster::Commands::Apply do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp_vpc' }
  let(:config) { double(find_stack: stack_definition) }
  let(:stack_definition) { StackMaster::Config::StackDefinition.new(
      region: 'us_east_1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures')
    )
  }

  before do
    allow(StackMaster::Stack).to receive(:find).with(region, stack_name).and_return(stack)
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(cf).to receive(:update_stack)
    allow(cf).to receive(:create_stack)
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
        template_body: stack_definition.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        capabilities: ['CAPABILITY_IAM']
      )
    end
  end

  context 'the stack does not exist' do
    let(:stack) { nil }

    it 'calls the create stack API method' do
      apply
      expect(cf).to have_received(:create_stack).with(
        stack_name: stack_name,
        template_body: stack_definition.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        tags: [
          {
            key: 'environment',
            value: 'production'
          }],
        capabilities: ['CAPABILITY_IAM']
      )
    end
  end
end
