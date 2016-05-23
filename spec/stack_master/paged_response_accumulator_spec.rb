RSpec.describe StackMaster::PagedResponseAccumulator do
  let(:cf) { Aws::CloudFormation::Client.new }
  subject(:accumulator) { described_class.new(cf, :describe_stack_events, { stack_name: 'blah' }, :stack_events) }

  context 'with one page' do
    let(:page_one_events) { [
      { event_id: '1', stack_id: '1', stack_name: 'blah', timestamp: Time.now},
      { event_id: '2', stack_id: '1', stack_name: 'blah', timestamp: Time.now}
    ] }

    before do
      cf.stub_responses(:describe_stack_events, { stack_events: page_one_events, next_token: nil })
    end

    it 'returns the first page' do
      events = accumulator.call
      expect(events.stack_events.count).to eq 2
    end
  end

  context 'with two pages' do
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
      events = accumulator.call
      expect(events.stack_events.count).to eq 3
    end
  end
end
