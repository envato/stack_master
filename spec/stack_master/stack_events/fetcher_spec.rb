RSpec.describe StackMaster::StackEvents::Fetcher do
  let(:cf) { Aws::CloudFormation::Client.new }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
  end

  context 'with 2 stack events' do
    let(:events) { [
      { event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: Time.now},
      { event_id: '2', stack_id: '1', stack_name: 'blah', timestamp: Time.now}
    ] }

    before do
      cf.stub_responses(:describe_stack_events, stack_events: events)
    end

    it 'returns stack events' do
      events = StackMaster::StackEvents::Fetcher.fetch('blah', 'us-east-1')
      expect(events.count).to eq 2
    end
  end

  context 'when more than one page is present' do
    let(:page_one_events) { [
      { event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: Time.now},
      { event_id: '2', stack_id: '1', stack_name: 'blah', timestamp: Time.now}
    ] }
    let(:page_two_events) { [
      { event_id: '3', stack_id: '1', stack_name: 'blah', timestamp: Time.now}
    ] }

    before do
      cf.stub_responses(:describe_stack_events, { stack_events: page_one_events, next_token: 'blah' }, { stack_events: page_two_events } )
    end

    it 'returns all the stack events combined' do
      events = StackMaster::StackEvents::Fetcher.fetch('blah', 'us-east-1')
      expect(events.count).to eq 3
    end
  end

  context 'filtering with a from timestamp' do
    let(:two_pm) { Time.parse('2015-10-27 14:00') }
    let(:three_pm) { Time.parse('2015-10-27 15:00') }
    let(:four_pm) { Time.parse('2015-10-27 16:00') }

    let(:events) {
      [
        { event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: two_pm },
        { event_id: '2', stack_id: '1', stack_name: 'blah', timestamp: four_pm },
      ]
    }

    before do
      cf.stub_responses(:describe_stack_events, stack_events: events)
    end

    it 'only returns events after the timestamp' do
      events = StackMaster::StackEvents::Fetcher.fetch('blah', 'us-east-1', from: three_pm)
      expect(events.map(&:event_id)).to eq ['2']
    end
  end
end
