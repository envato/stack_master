RSpec.describe StackMaster::ParameterResolvers::OnePassword do

  describe '#resolve' do
    let(:config) { double(base_dir: '/base') }
    let(:stack_definition) { double(stack_name: 'mystack', region: 'us-east-1') }
    subject(:resolver) { described_class.new(config, stack_definition) }
    let(:op_env_unset) { ENV['OP_SESSION_something'].clear  }
    let(:secureNote) {{
      "uuid" => "auuid",
      "vaultUuid" => "avaultuuid",
      "templateUuid" => "003",
      "createdAt" => "2018-01-17 07:28:11 +0000 UTC",
      "updatedAt" => "2018-01-17 07:28:11 +0000 UTC",
      "changerUuid" => "anotheruuid",
      "overview" => {
        "ainfo" => "begin message",
        "ps" => 0,
        "title" => "note title"
      },
      "details" => {
        "notesPlain" => "decrypted note",
        "sections" => [
          {
            "name" => "linked items",
            "title" => "Related Items"
          }
        ]
      }
    }}
    let(:password) {{
      "uuid" => "auuid",
      "vaultUuid" => "avaultuuid",
      "templateUuid" => "001",
      "createdAt" => "2018-03-24 01:55:07 +0000 UTC",
      "updatedAt" => "2018-03-24 01:55:07 +0000 UTC",
      "changerUuid" => "anotheruuid",
      "overview" => {
        "ainfo" => "pi",
        "ps" =>  84,
        "title" => "password title"
      },
      "details" => {
        "fields" => [
          {
            "designation" => "username",
            "name" => "username",
            "type" => "T",
            "value" => "theusername"
          },
          {
            "designation" => "password",
            "name" => "password",
            "type" => "P",
            "value" => "thepassword"
          }
        ],
        "sections" => [
          {
            "name" => "linked items",
            "title" => "Related Items"
          }
        ]
      }
    }}
    let(:the_password) {{
        'title' => 'password title',
        'type' => 'password',
        'vault' => 'Shared'
    }}
    let(:the_secureNote) {{
        'title' => 'note title',
        'type' => 'secureNote',
        'vault' => 'Shared'
    }}

    context 'when we have set OP_SESSION_ environment' do
      before do
        ENV['OP_SESSION_something'] = 'session'
      end
      context 'when retrieving a password' do
        it 'returns the password' do
        allow_any_instance_of(described_class).to receive(:`).with("op --version").and_return(true)
          allow_any_instance_of(described_class).to receive(:`).with("op get item --vault='Shared' 'password title' 2>&1").and_return(password.to_json)
          expect(resolver.resolve(the_password)).to eq 'thepassword'
        end      
      end
      context 'when retrieving a secureNote' do
        it 'returns the secureNote' do
        allow_any_instance_of(described_class).to receive(:`).with("op --version").and_return(true)
          allow_any_instance_of(described_class).to receive(:`).with("op get item --vault='Shared' 'note title' 2>&1").and_return(secureNote.to_json)
          expect(resolver.resolve(the_secureNote)).to eq 'decrypted note'
        end
      end
    end
    context 'when we have not set OP_SESSION_ environment' do
      context 'when retrieving a password' do
        it 'should raise error when ENV not set' do
          allow(ENV).to receive_message_chain(:keys, :grep).with(/OP_SESSION_\w+$/).and_return([])
          allow_any_instance_of(described_class).to receive(:`).with("op --version").and_return(true)
          allow_any_instance_of(described_class).to receive(:`).with("op get item --vault='Shared' 'password title' 2>&1").and_return(password.to_json)
          expect { resolver.resolve(the_password) }.to raise_error(RuntimeError, "1password requires the `OP_SESSION_<name>` to be set")
        end
      end
    end
    context 'when we op cli is not installed' do
      before do
        ENV['OP_SESSION_something'] = 'session'
      end
      
      it 'we return an error' do
        allow_any_instance_of(described_class).to receive(:`).with("op --version").and_raise(Errno::ENOENT)
        expect { resolver.resolve(the_password) }.to raise_error(StackMaster::ParameterResolvers::OnePassword::OnePasswordBinaryNotFound, "The op cli needs to be installed and in the PATH, No such file or directory")
      end
    end
    context 'when items are not found' do
      before do
        ENV['OP_SESSION_something'] = 'session'
      end
      it 'we return an error' do
        allow_any_instance_of(described_class).to receive(:`).with("op --version").and_return(true)
        allow_any_instance_of(described_class).to receive(:`).with("op get item --vault='Shared' 'password title' 2>&1").and_return('[LOG] 2018/03/26 09:56:02 (ERROR) Vault Shared not found.')
        expect { resolver.resolve(the_password) }.to raise_error(StackMaster::ParameterResolvers::OnePassword::OnePasswordNotFound, 'Failed to return item from 1password, (ERROR) Vault Shared not found.')
      end
    end
    context 'when returned value is invalid' do
      before do
        ENV['OP_SESSION_something'] = 'session'
      end
      it 'we return an error' do
        allow_any_instance_of(described_class).to receive(:`).with("op --version").and_return(true)
        allow_any_instance_of(described_class).to receive(:`).with("op get item --vault='Shared' 'password title' 2>&1").and_return('{key: value }')
        expect { resolver.resolve(the_password) }.to raise_error(StackMaster::ParameterResolvers::OnePassword::OnePasswordInvalidResponse, "Failed to parse JSON returned, {key: value }: 784: unexpected token at '{key: value }'")
      end
    end
  end
end
