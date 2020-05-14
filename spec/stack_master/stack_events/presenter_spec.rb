RSpec.describe StackMaster::StackEvents::Presenter do
  describe "#print_event" do
    let(:time) { Time.new(2001,1,1,2,2,2) }
    let(:event) do
      double(:event,
             timestamp:              time,
             logical_resource_id:    'MyAwesomeQueue',
             resource_type:          'AWS::SQS::Queue',
             resource_status:        'CREATE_IN_PROGRESS',
             resource_status_reason: 'Resource creation Initiated')
    end
    subject(:print_event) { described_class.print_event($stdout, event) }

    it "nicely presents event data" do
      expect { print_event }.to output("\e[33m2001-01-01 02:02:02 #{time.strftime('%z')} MyAwesomeQueue AWS::SQS::Queue CREATE_IN_PROGRESS Resource creation Initiated\e[0m\n").to_stdout
    end
  end
end
