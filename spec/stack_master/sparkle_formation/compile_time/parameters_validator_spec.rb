RSpec.describe StackMaster::SparkleFormation::CompileTime::ParametersValidator do

  let(:definitions) {{ip: {type: :string}}}
  let(:parameters) {{'Ip' => '10.0.0.0'}}
  let(:value_validator_factory) {instance_double(StackMaster::SparkleFormation::CompileTime::ValueValidatorFactory)}
  let(:value_validator) {instance_double(StackMaster::SparkleFormation::CompileTime::ValueValidator)}

  subject {described_class.new(definitions, parameters)}

  before(:each) do
    allow(StackMaster::SparkleFormation::CompileTime::ValueValidatorFactory)
        .to receive(:new).and_return(value_validator_factory)
    allow(value_validator_factory)
        .to receive(:build).and_return([value_validator])
    allow(value_validator).to receive(:validate)
    allow(value_validator).to receive(:is_valid).and_return(true)
  end

  describe '#validate' do

    it('should initialise the ValueValidatorFactory') do
      expect(StackMaster::SparkleFormation::CompileTime::ValueValidatorFactory).to receive(:new).with(:ip, {type: :string}, '10.0.0.0')
      subject.validate
    end

    it('should build validators') do
      expect(value_validator_factory).to receive(:build)
      subject.validate
    end

    it('should call validate on all validators') do
      expect(value_validator).to receive(:validate)
      subject.validate
    end

    context 'when the validators are valid' do

      before(:each) do
        allow(value_validator).to receive(:is_valid).and_return(true)
      end

      it('should not raise any error') do
        expect{subject.validate}.to_not raise_error
      end

    end

    context 'when the validators are invalid' do

      let(:error){'error'}

      before(:each) do
        allow(value_validator).to receive(:is_valid).and_return(false)
        allow(value_validator).to receive(:error).and_return(error)
      end

      it('should raise an error') do
        expect {subject.validate}.to raise_error(ArgumentError, "Invalid compile time parameter: #{error}")
      end

    end

  end

end