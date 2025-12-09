RSpec.describe StackMaster::StackEvents::Streamer do
  let(:events_first_call) {
    [
      OpenStruct.new(event_id: '1', resource_status: 'BLAH', timestamp: Time.now),
      OpenStruct.new(event_id: '2', resource_status: 'BLAH', timestamp: Time.now),
      OpenStruct.new(event_id: '3', resource_status: 'BLAH', timestamp: Time.now),
    ]
  }
  let(:events_second_call) {
    events_first_call + [
      OpenStruct.new(
        event_id: '4',
        resource_status: 'UPDATE_COMPLETE',
        resource_type: 'AWS::CloudFormation::Stack',
        logical_resource_id: stack_name,
        timestamp: Time.now
      )
    ]
  }
  let(:stack_name) { 'stack-name' }
  let(:region) { 'us-east-1' }
  let(:now) { Time.now }

  before do
    allow(StackMaster::StackEvents::Fetcher)
      .to receive(:fetch)
      .with(stack_name, region, from: now)
      .and_return(events_first_call, events_second_call)
    allow(Time).to receive(:now).and_return(now)
  end

  it 'returns after seeing a finish state' do
    events = []
    StackMaster::StackEvents::Streamer.stream(stack_name, region, sleep_between_fetches: 0) do |event|
      events << event
    end
  end

  it 'streams events to an io object' do
    io = StringIO.new
    StackMaster::StackEvents::Streamer.stream(stack_name, region, sleep_between_fetches: 0, io: io)
    expect(io.string).to include('UPDATE_COMPLETE')
  end

  context "the stack is in a failed state" do
    let(:events_second_call) {
      events_first_call + [
        OpenStruct.new(
          event_id: '4',
          resource_status: 'ROLLBACK_FAILED',
          resource_type: 'AWS::CloudFormation::Stack',
          logical_resource_id: stack_name,
          timestamp: Time.now
        )
      ]
    }

    it 'raises an error on failure' do
      expect { StackMaster::StackEvents::Streamer.stream(stack_name, region, sleep_between_fetches: 0) }
        .to raise_error(StackMaster::StackEvents::Streamer::StackFailed)
    end
  end
end
