RSpec.describe StackMaster::StackEvents::Fetcher do
  let(:cf) { Aws::CloudFormation::Client.new }
  let(:stack_name) { 'blah' }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
    allow(StackMaster::PagedResponseAccumulator).to receive(:call).with(StackMaster.cloud_formation_driver, :describe_stack_events, { stack_name: stack_name }, :stack_events).and_return(OpenStruct.new(stack_events: events))
  end

  context 'with 2 stack events' do
    let(:events) { [
      OpenStruct.new(event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: Time.now),
      OpenStruct.new(event_id: '2', stack_id: '1', stack_name: 'blah', timestamp: Time.now)
    ] }

    it 'returns stack events' do
      events = StackMaster::StackEvents::Fetcher.fetch(stack_name, 'us-east-1')
      expect(events.count).to eq 2
    end
  end

  context 'filtering with a from timestamp' do
    let(:two_pm) { Time.parse('2015-10-27 14:00') }
    let(:three_pm) { Time.parse('2015-10-27 15:00') }
    let(:four_pm) { Time.parse('2015-10-27 16:00') }

    let(:events) {
      [
        OpenStruct.new(event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: two_pm),
        OpenStruct.new(event_id: '2', stack_id: '1', stack_name: 'blah', timestamp: four_pm),
      ]
    }

    it 'only returns events after the timestamp' do
      events = StackMaster::StackEvents::Fetcher.fetch(stack_name, 'us-east-1', from: three_pm)
      expect(events.map(&:event_id)).to eq ['2']
    end
  end
end
