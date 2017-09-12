RSpec.shared_examples 'validate valid parameter' do |parameter|
  context "with parameter #{parameter}" do
    subject(:validator) { described_class.new('name', definition, parameter).tap {|validator| validator.validate} }

    it 'is valid' do
      expect(validator.is_valid).to be_truthy
    end
  end
end

RSpec.shared_examples 'validate invalid parameter' do |parameter, errors|
  context "with parameter #{parameter}" do
    subject(:validator) { described_class.new(name, definition, parameter).tap {|validator| validator.validate} }

    it 'is not valid' do
      expect(validator.is_valid).to be_falsey
    end

    it 'has an error' do
      expect(validator.error).to eql error_message.call(errors, definition)
    end
  end
end
