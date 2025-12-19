require 'stack_master/test_driver/cloud_formation'

RSpec.describe StackMaster::TestDriver::CloudFormation do
  subject(:test_cf_driver) { described_class.new }

  context 'stacks' do
    it 'creates and describes stacks' do
      test_cf_driver.create_stack(stack_id: "1", stack_name: 'stack-1')
      test_cf_driver.create_stack(stack_id: "2", stack_name: 'stack-2')
      expect(test_cf_driver.describe_stacks.stacks.map(&:stack_id)).to eq(%w[1 2])
    end

    it 'adds and gets stack events' do
      test_cf_driver.add_stack_event(stack_name: 'stack-1', resource_status: "UPDATE_COMPLETE")
      test_cf_driver.add_stack_event(stack_name: 'stack-1', resource_status: "UPDATE_COMPLETE")
      test_cf_driver.add_stack_event(stack_name: 'stack-2')
      expect(test_cf_driver.describe_stack_events(stack_name: 'stack-1').stack_events.map(&:stack_name))
        .to eq(%w[stack-1 stack-1])
    end

    it 'sets and gets templates' do
      test_cf_driver.set_template('stack-1', 'blah')
      expect(test_cf_driver.get_template(stack_name: 'stack-1').template_body).to eq 'blah'
    end

    it 'sets and gets stack policies' do
      stack_policy_body = '{}'
      test_cf_driver.set_stack_policy(stack_name: 'stack-1', stack_policy_body: stack_policy_body)
      expect(test_cf_driver.get_stack_policy(stack_name: 'stack-1').stack_policy_body).to eq(stack_policy_body)
    end
  end

  context 'change sets' do
    it 'creates and describes change sets' do
      change_set_id = test_cf_driver.create_change_set(
        stack_name: 'stack-1',
        change_set_name: 'change-set-1',
        template_body: '{}',
        parameters: [{ paramater_key: 'param_1', parameter_value: 'value_1' }]
      ).id
      change_set = test_cf_driver.describe_change_set(change_set_name: change_set_id)
      expect(change_set.change_set_id).to eq change_set_id
      expect(change_set.change_set_name).to eq 'change-set-1'
      change_set = test_cf_driver.describe_change_set(change_set_name: 'change-set-1')
      expect(change_set.change_set_id).to eq change_set_id
      expect(change_set.change_set_name).to eq 'change-set-1'
    end

    it 'creates stacks using change sets and describes stacks' do
      change_set1 = test_cf_driver.create_change_set(
        change_set_name: 'change-set-1',
        stack_name: 'stack-1',
        change_set_type: 'CREATE'
      )
      change_set2 = test_cf_driver.create_change_set(
        change_set_name: 'change-set-2',
        stack_name: 'stack-2',
        change_set_type: 'CREATE'
      )
      test_cf_driver.execute_change_set(change_set_name: change_set1.id)
      test_cf_driver.execute_change_set(change_set_name: change_set2.id)
      expect(test_cf_driver.describe_stacks.stacks.map(&:stack_name)).to eq(%w[stack-1 stack-2])
    end
  end

  it 'deletes change sets' do
    change_set_id = test_cf_driver.create_change_set(stack_name: '1', change_set_name: '2').id
    test_cf_driver.delete_change_set(change_set_name: change_set_id)
    expect do
      test_cf_driver.describe_change_set(change_set_name: change_set_id)
    end.to raise_error(KeyError)
  end
end
