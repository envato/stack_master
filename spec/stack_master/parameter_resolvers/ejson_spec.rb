RSpec.describe StackMaster::ParameterResolvers::Ejson do
  let(:base_dir) { '/base_dir' }
  let(:config) { double(base_dir: base_dir) }
  let(:ejson_file) { 'staging.ejson' }
  let(:stack_definition) { double(ejson_file: ejson_file, stack_name: 'mystack', region: 'us-east-1') }
  subject(:ejson) { described_class.new(config, stack_definition) }
  let(:secrets) { { secret_a: 'value_a' } }

  before do
    allow(EJSONWrapper).to receive(:decrypt).and_return(secrets)
  end

  it 'returns secrets' do
    expect(ejson.resolve('secret_a')).to eq('value_a')
  end

  context 'when decryption fails' do
    before do
      allow(EJSONWrapper).to receive(:decrypt).and_raise(EJSONWrapper::DecryptionFailed)
    end

    it 'bubbles the error up' do
      expect { ejson.resolve('test') }.to raise_error(EJSONWrapper::DecryptionFailed)
    end
  end

  context 'when ejson_file not specified' do
    let(:ejson_file) { nil }

    it 'raises an error' do
      expect { ejson.resolve('test') }.to raise_error(ArgumentError, /No ejson_file defined/)
    end
  end
end