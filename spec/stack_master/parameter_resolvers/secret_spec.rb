RSpec.describe StackMaster::ParameterResolvers::Secret, :if => OS.windows? do
  let(:config) { double(base_dir: 'C:\base_dir') }
  let(:stack_definition) { double(secret_file: "my_file.yml.gpg", stack_name: 'mystack', region: 'us-east-1') }
  subject(:resolve_secret) { StackMaster::ParameterResolvers::Secret.new(config, stack_definition).resolve('my_file/my_secret_key') }

  it 'raises an PlatformNotSupported exception' do
    expect {
      resolve_secret
    }.to raise_error(StackMaster::ParameterResolvers::Secret::PlatformNotSupported)
  end
end

RSpec.describe StackMaster::ParameterResolvers::Secret, :unless => OS.windows? do
  let(:base_dir) { '/base_dir' }
  let(:config) { double(base_dir: base_dir) }
  let(:stack_definition) { double(secret_file: secrets_file_name, stack_name: 'mystack', region: 'us-east-1') }
  subject(:resolve_secret) { StackMaster::ParameterResolvers::Secret.new(config, stack_definition).resolve(value) }
  let(:value) { 'my_file/my_secret_key' }
  let(:secrets_file_name) { "my_file.yml.gpg" }
  let(:file_path) { "#{base_dir}/secrets/#{secrets_file_name}" }

  context 'the secret file does not exist' do
    before do
      allow(File).to receive(:exist?).with(file_path).and_return(false)
    end

    it 'raises an ArgumentError with the location of the expected secret file' do
      expect {
        resolve_secret
      }.to raise_error(ArgumentError, /#{file_path}/)
    end
  end

  context 'no secret file is specified for the stack definition' do
    before do
      allow(stack_definition).to receive(:secret_file).and_return(nil)
    end

    it 'raises an ArgumentError with the location of the expected secret file' do
      expect {
        resolve_secret
      }.to raise_error(ArgumentError, /No secret_file defined/)
    end
  end

  context 'the secret file exists' do
    let(:dir) { double(Dotgpg::Dir) }
    let(:decrypted_file) { <<EOF }
secret_key_1: secret_value_1
secret_key_2: secret_value_2
EOF

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(Dotgpg::Dir).to receive(:closest).with(file_path).and_return(dir)
      allow(dir).to receive(:decrypt).with("secrets/#{secrets_file_name}", anything)
      allow(StringIO).to receive(:new).and_return(double(string: decrypted_file))
    end

    context 'the secret key does not exist' do
      let(:value) { 'unknown_secret' }

      it 'raises a secret not found error' do
        expect {
          resolve_secret
        }.to raise_error(StackMaster::ParameterResolvers::Secret::SecretNotFound)
      end
    end

    context 'the secret key exists' do
      let(:value) { 'secret_key_2' }

      it 'returns the secret' do
        expect(resolve_secret).to eq('secret_value_2')
      end
    end
  end
end
