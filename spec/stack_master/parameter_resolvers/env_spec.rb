RSpec.describe StackMaster::ParameterResolvers::Env do

  describe '#resolve' do

    subject(:resolver) { described_class.new(nil, double(region: 'us-east-1')) }
    let(:environment_variable_name) { 'TEST' }
    let(:error) { "The environment variable #{environment_variable_name} is not set" }

    before(:each) do
      ENV.delete(environment_variable_name)
    end

    context 'the environment variable is defined' do
      it 'should return the environment variable value' do
        ENV[environment_variable_name] = 'a'
        expect(resolver.resolve(environment_variable_name)).to eq 'a'
      end
    end

    context 'the environment variable is undefined' do
      it 'should raise and error' do
        expect { resolver.resolve(environment_variable_name) }
            .to raise_error(ArgumentError, error)
      end
    end

    context 'the environment variable is defined but empty' do
      it 'should raise and error' do
        ENV[environment_variable_name] = ''
        expect { resolver.resolve(environment_variable_name) }
            .to raise_error(ArgumentError, error)
      end
    end

  end
end
