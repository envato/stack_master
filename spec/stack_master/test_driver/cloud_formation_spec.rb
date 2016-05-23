require 'stack_master/test_driver/cloud_formation'

RSpec.describe StackMaster::TestDriver::CloudFormation do
  subject(:test_cf_driver) { described_class.new }

  context 'stacks' do
    it 'creates and describes stacks' do
      test_cf_driver.create_stack(stack_id: "1", stack_name: 'stack-1')
      test_cf_driver.create_stack(stack_id: "2", stack_name: 'stack-2')
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

  context 'change sets' do
    it 'creates and describes change sets' do
      change_set_id = test_cf_driver.create_change_set(
        stack_name: 'stack-1',
        change_set_name: 'change-set-1',
        template_body: '{}',
        parameters: [{ paramater_key: 'param_1', parameter_value: 'value_1'}]
      ).id
      change_set = test_cf_driver.describe_change_set(change_set_name: change_set_id)
      expect(change_set.change_set_id).to eq change_set_id
      expect(change_set.change_set_name).to eq 'change-set-1'
      change_set = test_cf_driver.describe_change_set(change_set_name: 'change-set-1')
      expect(change_set.change_set_id).to eq change_set_id
      expect(change_set.change_set_name).to eq 'change-set-1'
    end
  end

  it 'deletes change sets' do
    change_set_id = test_cf_driver.create_change_set(stack_name: '1', change_set_name: '2').id
    test_cf_driver.delete_change_set(change_set_name: change_set_id)
    expect {
      test_cf_driver.describe_change_set(change_set_name: change_set_id)
    }.to raise_error(KeyError)
  end
end
