RSpec.shared_examples 'validate valid parameter' do |validator_class, parameter|
  context "with parameter #{parameter}" do
    subject(:validator) { validator_class.new('name', definition, parameter).tap {|validator| validator.validate} }

    it 'is valid' do
      expect(validator.is_valid).to be_truthy
    end
  end
end

RSpec.shared_examples 'validate invalid parameter' do |validator_class, parameter, errors|
  context "with parameter #{parameter}" do
    subject(:validator) { validator_class.new(name, definition, parameter).tap {|validator| validator.validate} }

    it 'is not valid' do
      expect(validator.is_valid).to be_falsey
    end

    it 'has an error' do
      expect(validator.error).to eql error_message.call(errors, definition)
    end
  end
end
