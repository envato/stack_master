require 'stack_master/test_driver/cloud_formation'

RSpec.describe StackMaster::TestDriver::CloudFormation do
  subject(:test_cf_driver) { described_class.new }

  it 'adds and gets stacks' do
    test_cf_driver.add_stack(stack_id: "1", stack_name: 'stack-1')
    test_cf_driver.add_stack(stack_id: "2", stack_name: 'stack-2')
    expect(test_cf_driver.describe_stacks.stacks.map(&:stack_id)).to eq(["1", "2"])

  end

  it 'adds and gets stack events' do
    test_cf_driver.add_stack_event(stack_name: 'stack-1', resource_status: "UPDATE_COMPLETE")
    test_cf_driver.add_stack_event(stack_name: 'stack-1', resource_status: "UPDATE_COMPLETE")
    test_cf_driver.add_stack_event(stack_name: 'stack-2')
    expect(test_cf_driver.describe_stack_events(stack_name: 'stack-1').stack_events.map(&:stack_name)).to eq ['stack-1', 'stack-1']
  end

  it 'sets and gets templates' do
    test_cf_driver.set_template('stack-1', 'blah')
    expect(test_cf_driver.get_template(stack_name: 'stack-1').template_body).to eq 'blah'
  end
end
