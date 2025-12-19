RSpec.describe StackMaster::ChangeSet do
  let(:cf) { instance_double(Aws::CloudFormation::Client) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:change_set_name) { 'changeset-123' }

  describe '.generate_change_set_name' do
    context 'valid name' do
      it 'creates a valid name' do
        expect(StackMaster::ChangeSet.generate_change_set_name('foobar')).to match(/^foobar-StackMaster[-a-zA-Z0-9]*$/)
      end
    end
  end

  describe '.create' do
    before do
      allow(StackMaster::ChangeSet).to receive(:generate_change_set_name).and_return(change_set_name)
      allow(StackMaster).to receive(:cloud_formation_driver).and_return(cf)
      allow(cf).to receive(:create_change_set).and_return(double(id: 'id-1'))
    end

    context 'successful response' do
      before do
        allow(cf)
          .to receive(:describe_change_set)
          .with({ change_set_name: 'id-1', next_token: nil })
          .and_return(
            double(
              next_token: nil,
              changes: [],
              :changes= => nil,
              :next_token= => nil,
              status: 'CREATE_COMPLETE'
            )
          )
      end

      it 'calls the create change set API with the addition of a name' do
        change_set = StackMaster::ChangeSet.create(stack_name: '123')
        expect(cf)
          .to have_received(:create_change_set)
          .with({ stack_name: '123', change_set_name: change_set_name })
        expect(change_set.failed?).to eq false
      end
    end

    context 'unsuccessful response' do
      before do
        allow(cf)
          .to receive(:describe_change_set)
          .with({ change_set_name: 'id-1', next_token: nil })
          .and_return(
            double(
              next_token: nil,
              changes: [],
              :changes= => nil,
              :next_token= => nil,
              status: 'FAILED',
              status_reason: 'No changes'
            )
          )
      end

      it 'is marked as failed' do
        change_set = StackMaster::ChangeSet.create(stack_name: '123')
        expect(change_set.failed?).to eq true
      end
    end
  end

  describe '#display' do
    context 'a successful response' do
      let(:target) { OpenStruct.new(name: 'GroupDescription', attribute: 'Properties', requires_recreation: 'Always') }
      let(:changes) do
        [
          OpenStruct.new(
            resource_change: OpenStruct.new(
              replacement: 'True',
              action: 'Modify',
              resource_type: 'EC2::Instance',
              logical_resource_id: '123',
              details: [
                OpenStruct.new(
                  target: target,
                  change_source: 'DirectModification',
                  evaluation: 'Static',
                  causing_entity: 'blah'
                )
              ]
            )
          )
        ]
      end
      let(:cf_response) do
        double(
          next_token: nil,
          changes: changes,
          :changes= => nil,
          :next_token= => nil,
          status: 'FAILED',
          status_reason: 'No changes'
        )
      end
      let(:io) { StringIO.new }
      subject(:change_set) { StackMaster::ChangeSet.new(cf_response) }
      let(:message) { io.string }
      before { change_set.display(io) }

      it 'outputs key data' do
        expect(message).to include 'Replace EC2::Instance 123'
      end

      it 'outputs detail data' do
        expect(message)
          .to include('Properties.GroupDescription. Always requires recreation. Triggered by: DirectModification.blah')
      end
    end
  end
end
