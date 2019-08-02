RSpec.describe StackMaster::ParameterResolvers::Ejson do
  let(:base_dir) { '/base_dir' }
  let(:config) { double(base_dir: base_dir) }
  let(:ejson_file) { 'staging.ejson' }
  let(:ejson_file_region) { 'ap-southeast-2' }
  let(:stack_definition) { double(ejson_file: ejson_file, ejson_file_region: ejson_file_region, stack_name: 'mystack', region: 'us-east-1') }
  subject(:ejson) { described_class.new(config, stack_definition) }
  let(:secrets) { { secret_a: 'value_a' } }

  before do
    allow(EJSONWrapper).to receive(:decrypt).and_return(secrets)
  end

  it 'returns secrets' do
    expect(ejson.resolve('secret_a')).to eq('value_a')
  end

  context 'when ejson_file_region is unspecified' do
    let(:ejson_file_region) { nil }

    it 'decrypts with the correct file path' do
      ejson.resolve('secret_a')
      expect(EJSONWrapper).to have_received(:decrypt).with('/base_dir/secrets/staging.ejson', use_kms: true, region: StackMaster.cloud_formation_driver.region)
    end
  end

  context 'when ejson_file_region is unspecified' do
    let(:ejson_file_region) { 'ap-southeast-2' }

    it 'decrypts with the correct file path' do
      ejson.resolve('secret_a')
      expect(EJSONWrapper).to have_received(:decrypt).with('/base_dir/secrets/staging.ejson', use_kms: true, region: 'ap-southeast-2')
    end
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
