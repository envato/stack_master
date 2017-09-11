RSpec.shared_examples "validate valid parameter" do |validator_class, parameter|
  context parameter.to_s do
    subject(:valid_parameter_validator) { validator_class.new('name', validator_definition, parameter).tap {|validator| validator.validate} }

    it 'is valid' do
      expect(valid_parameter_validator.is_valid).to be_truthy
    end
  end
end

RSpec.shared_examples "validate invalid parameter" do |validator_class, parameter, errored_parameters|
  context parameter.to_s do
    subject(:invalid_parameter_validator) { validator_class.new(name, validator_definition, parameter).tap {|validator| validator.validate} }

    it 'is not valid' do
      expect(invalid_parameter_validator.is_valid).to be_falsey
    end

    it 'has an error' do
      puts parameter
      expect(invalid_parameter_validator.error).to eql error_message.call(errored_parameters, validator_definition)
    end
  end
end
