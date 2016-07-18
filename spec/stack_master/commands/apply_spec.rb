RSpec.describe StackMaster::Commands::Apply do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:s3) { instance_double(Aws::S3::Client) }
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
    allow(config).to receive(:stack_defaults).and_return({})
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
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
    let(:change_set) { double(display: true, failed?: false, id: 'id-1') }

    before do
      allow(cf).to receive(:create_change_set).and_return(OpenStruct.new(id: '1'))
      allow(StackMaster::ChangeSet).to receive(:create).and_return(change_set)
      allow(cf).to receive(:execute_change_set).and_return(OpenStruct.new(id: '1'))
    end

    it 'creates a change set' do
      apply
      expect(StackMaster::ChangeSet).to have_received(:create).with(
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

    context 'when using s3' do
      before do
        stack_definition.s3 = {
          'bucket' => 'my-bucket',
          'prefix' => 'my-prefix',
          'region' => 'us-east-1',
        }
        stack_definition.template = 'my-template.rb'
        allow(s3).to receive(:list_objects).and_return([])
        allow(s3).to receive(:put_object)
      end

      it 'uploads to the correct URL' do
        apply
        expect(s3).to have_received(:put_object).with(
          bucket: 'my-bucket',
          key: 'my-prefix/my-template.json',
          body: template_body,
          metadata: { md5: Digest::MD5.hexdigest(template_body).to_s }
        )
      end
    end

    context 'the changeset failed to create' do
      before do
        allow(change_set).to receive(:failed?).and_return(true)
        allow(change_set).to receive(:status_reason).and_return('reason')
      end

      it 'outputs the status reason' do
        expect { apply }.to output(/reason/).to_stdout
      end
    end

    context 'user decides to not apply the change set' do
      before do
        allow(StackMaster).to receive(:non_interactive_answer).and_return('n')
        allow(StackMaster::ChangeSet).to receive(:delete)
        allow(StackMaster::ChangeSet).to receive(:execute)
        apply
      end

      it 'deletes the change set' do
        expect(StackMaster::ChangeSet).to have_received(:delete).with(change_set.id)
      end

      it "doesn't execute the change set" do
        expect(StackMaster::ChangeSet).to_not have_received(:execute).with(change_set.id)
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
