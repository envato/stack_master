RSpec.describe StackMaster::Commands::Apply do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:s3) { instance_double(Aws::S3::Client) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:config) { double(find_stack: stack_definition) }
  let(:role_arn) { 'test_service_role_arn' }
  let(:notification_arn) { 'test_arn' }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: region, stack_name: stack_name) }
  let(:template_body) { '{}' }
  let(:template_format) { :json }
  let(:parameters) { { 'param_1' => 'hello' } }
  let(:proposed_stack) { StackMaster::Stack.new(template_body: template_body, template_format: template_format, tags: { 'environment' => 'production' } , parameters: parameters, role_arn: role_arn, notification_arns: [notification_arn], stack_policy_body: stack_policy_body ) }
  let(:stack_policy_body) { '{}' }
  let(:change_set) { double(display: true, failed?: false, id: '1') }
  let(:differ) { instance_double(StackMaster::StackDiffer, output_diff: nil, single_param_update?: false) }

  before do
    allow(StackMaster::Stack).to receive(:find).with(region, stack_name).and_return(stack)
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
    allow(config).to receive(:stack_defaults).and_return({})
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    allow(cf).to receive(:create_stack)
    allow(StackMaster::StackDiffer).to receive(:new).with(proposed_stack, stack).and_return(differ)
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
    allow(StackMaster).to receive(:interactive?).and_return(false)
    allow(cf).to receive(:create_change_set).and_return(OpenStruct.new(id: '1'))
    allow(StackMaster::ChangeSet).to receive(:create).and_return(change_set)
    allow(cf).to receive(:execute_change_set).and_return(OpenStruct.new(id: '1'))
    allow(cf).to receive(:set_stack_policy)
  end

  def apply
    StackMaster::Commands::Apply.perform(config, stack_definition)
  end

  context 'the stack exist' do
    let(:stack) { StackMaster::Stack.new(stack_id: '1') }

    it 'creates a change set' do
      apply
      expect(StackMaster::ChangeSet).to have_received(:create).with(
        stack_name: stack_name,
        template_body: proposed_stack.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        tags: [
          { key: 'environment', value: 'production' }
        ],
        capabilities: ['CAPABILITY_IAM', 'CAPABILITY_NAMED_IAM'],
        role_arn: role_arn,
        notification_arns: [notification_arn]
      )
    end

    it 'streams events' do
      Timecop.freeze(Time.local(1990)) do
        apply
        expect(StackMaster::StackEvents::Streamer).to have_received(:stream).with(stack_name, region, io: STDOUT, from: Time.now)
      end
    end

    it 'attaches a stack policy to the stack' do
      apply
      expect(cf).to have_received(:set_stack_policy).with(
        stack_name: stack_name,
        stack_policy_body: stack_policy_body
      )
    end

    context 'stack policy is not changed' do
      let(:stack) { StackMaster::Stack.new(stack_id: '1', stack_policy_body: stack_policy_body) }

      it 'does not set a stack policy' do
        apply
        expect(cf).to_not have_received(:set_stack_policy)
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

      it 'uploads to S3 before creating a changeset' do
        expect(s3).to receive(:put_object).ordered
        expect(StackMaster::ChangeSet).to receive(:create).ordered
        apply
      end
    end

    context 'the changeset failed to create' do
      before do
        allow(StackMaster::ChangeSet).to receive(:delete)
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

    context 'yes_param option is set' do
      let(:yes_param) { 'YesParam' }
      let(:options) { double(yes_param: yes_param).as_null_object }

      before do
        allow(StackMaster).to receive(:non_interactive_answer).and_return('n')
        allow(differ).to receive(:single_param_update?).with(yes_param).and_return(true)
      end

      it "skips asking for confirmation on single param updates" do
        expect(StackMaster::ChangeSet).to receive(:execute).with(change_set.id, stack_name)
        StackMaster::Commands::Apply.perform(config, stack_definition, options)
      end
    end
  end

  context 'the stack does not exist' do
    let(:stack) { nil }

    it 'creates a change set for a new stack' do
      apply
      expect(StackMaster::ChangeSet).to have_received(:create).with(
        stack_name: stack_name,
        template_body: proposed_stack.template_body,
        parameters: [
          { parameter_key: 'param_1', parameter_value: 'hello' }
        ],
        tags: [
          { key: 'environment', value: 'production' }
        ],
        capabilities: ['CAPABILITY_IAM', 'CAPABILITY_NAMED_IAM'],
        role_arn: role_arn,
        notification_arns: [notification_arn],
        change_set_type: 'CREATE'
      )
    end

    context 'on_failure option is set' do
      it 'calls the create stack API method' do
        options = Commander::Command::Options.new
        options.on_failure = 'ROLLBACK'
        StackMaster::Commands::Apply.perform(config, stack_definition, options)
        apply
        expect(cf).to have_received(:create_stack).with(
          stack_name: stack_name,
          template_body: proposed_stack.template_body,
          parameters: [
            { parameter_key: 'param_1', parameter_value: 'hello' }
          ],
          tags: [
            { key: 'environment', value: 'production' }
          ],
          capabilities: ['CAPABILITY_IAM', 'CAPABILITY_NAMED_IAM'],
          role_arn: role_arn,
          notification_arns: [notification_arn],
          on_failure: 'ROLLBACK'
        )
      end
    end

    it 'attaches a stack policy to the created stack' do
      apply
      expect(cf).to have_received(:set_stack_policy).with(
        stack_name: stack_name,
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

    context 'user decides to not create a stack' do
      before do
        allow(StackMaster).to receive(:non_interactive_answer).and_return('n')
        allow(cf).to receive(:delete_stack)
        allow(StackMaster::ChangeSet).to receive(:execute)
        apply
      end

      it 'deletes the stack' do
        expect(cf).to have_received(:delete_stack).with(stack_name: stack_name)
      end

      it "doesn't execute the change set" do
        expect(StackMaster::ChangeSet).to_not have_received(:execute).with(change_set.id)
      end
    end

    context 'user uses ctrl+c' do
      before do
        allow(StackMaster).to receive(:non_interactive_answer).and_return('n')
        allow(cf).to receive(:delete_stack)
        allow(StackMaster::ChangeSet).to receive(:create).and_raise(StackMaster::CtrlC)
      end

      it "deletes the stack" do
        expect(cf).to receive(:delete_stack).with(stack_name: stack_name)
        expect { apply }.to raise_error
      end
    end
  end

  context 'stack is in review_in_progress' do
    let(:stack) { StackMaster::Stack.new(stack_id: '1', stack_name: 'mistack', stack_status: 'REVIEW_IN_PROGRESS')}

    it 'abort and fails with error' do
      expect{ apply }.to output("Stack currently exists and is in REVIEW_IN_PROGRESS\nYou will need to delete the stack (mistack) before continuing\n").to_stderr
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
