RSpec.describe StackMaster::Commands::Apply do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:config) { double(find_stack: stack_definition) }
  let(:notification_arn) { 'test_arn' }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: region, stack_name: stack_name) }
  let(:template_body) { '{}' }
  let(:parameters) { { 'param_1' => 'hello' } }
  let(:proposed_stack) { StackMaster::Stack.new(template_body: template_body, tags: { 'environment' => 'production' } , parameters: parameters, notification_arns: [notification_arn], stack_policy_body: stack_policy_body ) }
  let(:stack_policy_body) { '{}' }

  before do
    allow(StackMaster::Stack).to receive(:find).with(region, stack_name).and_return(stack)
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(cf).to receive(:create_stack)
    allow(StackMaster::StackDiffer).to receive(:new).with(proposed_stack, stack).and_return double.as_null_object
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
    allow(StackMaster).to receive(:interactive?).and_return(false)
  end

  def apply
    StackMaster::Commands::Apply.perform(config, stack_definition)
  end

  context 'the stack exist' do
    let(:stack) { StackMaster::Stack.new(stack_id: '1') }

    before do
      allow(cf).to receive(:create_change_set).and_return(OpenStruct.new(id: '1'))
      allow(StackMaster::DisplayChangeSet).to receive(:perform).and_return(double(success?: true))
      allow(cf).to receive(:execute_change_set).and_return(OpenStruct.new(id: '1'))
    end

    it 'calls the create_change_set API method' do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      apply
      expect(cf).to have_received(:create_change_set).with(
        stack_name: stack_name,
        template_body: proposed_stack.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        capabilities: ['CAPABILITY_IAM'],
        notification_arns: [notification_arn],
        stack_policy_body: stack_policy_body,
        change_set_name: "StackMaster#{now.strftime('%Y-%m-%e-%H%M-%s')}"
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
        allow(cf).to receive(:execute_change_set).with(anything).and_raise(Aws::CloudFormation::Errors::ServiceError.new('a', 'the message'))
      end

      it 'outputs the message' do
        expect { apply }.to output(/the message/).to_stderr
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
        expect { apply }.to output(/The \(space compressed\) stack is larger than the limit set by AWS/).to_stderr
      end
    end

    it 'streams events' do
      Timecop.freeze(Time.local(1990)) do
        apply
        expect(StackMaster::StackEvents::Streamer).to have_received(:stream).with(stack_name, region, io: STDOUT, from: Time.now)
      end
    end
  end

  context 'one or more parameters are empty' do
    let(:stack) { StackMaster::Stack.new(stack_id: '1', parameters: parameters) }
    let(:parameters) { { 'param_1' => nil } }

    it "doesn't allow apply" do
      expect { apply }.to_not output(/Continue and apply the stack/).to_stdout
    end

    it 'outputs a description of the problem' do
      expect { apply }.to output(/Empty\/blank parameters detected/).to_stderr
    end

    it 'outputs where param files are loaded from' do
      stack_definition.parameter_files.each do |parameter_file|
        expect { apply }.to output(/#{parameter_file}/).to_stderr
      end
    end
  end
end
