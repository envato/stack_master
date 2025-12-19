Aws.config[:stub_responses] = true

module AwsHelpers
  def stub_drift_detection(stack_drift_detection_id: '1', stack_drift_status: 'IN_SYNC')
    cfn.stub_responses(:detect_stack_drift, { stack_drift_detection_id: stack_drift_detection_id })
    cfn.stub_responses(
      :describe_stack_drift_detection_status,
      {
        stack_id: '1',
        timestamp: Time.now,
        stack_drift_detection_id: stack_drift_detection_id,
        stack_drift_status: stack_drift_status,
        detection_status: 'DETECTION_COMPLETE'
      }
    )
  end

  def stub_stack_resource_drift(stack_name:, stack_resource_drifts:)
    cfn.stub_responses(:describe_stack_resource_drifts, { stack_resource_drifts: stack_resource_drifts })
  end
end

RSpec.configure do |config|
  config.include(AwsHelpers)
end
