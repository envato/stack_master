RSpec.shared_examples "validate valid parameter" do |validator_class, parameter|
  context parameter.to_s do
    subject(:valid_parameter_validator) { validator_class.new('name', validator_definition, parameter).tap {|validator| validator.validate} }

    it 'is valid' do
      expect(valid_parameter_validator.is_valid).to be_truthy
    end
  end
end

RSpec.shared_examples "validate invalid parameter" do |validator_class, parameter, error|
  context parameter.to_s do
    subject(:invalid_parameter_validator) { validator_class.new('name', validator_definition, parameter).tap {|validator| validator.validate} }

    it 'is not valid' do
      expect(invalid_parameter_validator.is_valid).to be_falsey
    end

    it 'has an error' do
      expect(invalid_parameter_validator.error).to eql "name:#{error} #{error_message}:#{validator_definition[error_parameter_key]}"
    end
  end
end
