def validate_valid_parameter(parameter)
  context "with parameter #{parameter}" do
    subject { described_class.new('name', definition, parameter).tap { |validator| validator.validate } }

    it 'is valid' do
      expect(subject.is_valid).to be_truthy
    end
  end
end

def validate_invalid_parameter(parameter, errors)
  context "with parameter #{parameter}" do
    subject { described_class.new(name, definition, parameter).tap { |validator| validator.validate } }

    it 'is not valid' do
      expect(subject.is_valid).to be_falsey
    end

    it 'has an error' do
      expect(subject.error).to eql error_message.call(errors, definition)
    end
  end
end
