RSpec.shared_examples "validate valid parameter" do |validator_class, parameter|
  subject(:valid_parameter_validator) { validator_class.new('name', validator_definition, parameter).tap {|validator| validator.validate} }

  it 'should be valid' do
    expect(valid_parameter_validator.is_valid).to be_truthy
  end
end

RSpec.shared_examples "validate invalid parameter" do |validator_class, parameter, error|
  subject(:invalid_parameter_validator) { validator_class.new('name', validator_definition, parameter).tap {|validator| validator.validate} }

  it 'should not be valid' do
    expect(invalid_parameter_validator.is_valid).to be_falsey
  end

  it 'should have an error' do
    expect(invalid_parameter_validator.error).to eql "name:#{error} does not match allowed_pattern:#{validator_definition[:allowed_pattern]}"
  end
end