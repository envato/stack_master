RSpec.describe StackMaster::ParameterResolver do
  subject(:parameter_resolver) { StackMaster::ParameterResolver.new(config, region, params) }
  let(:params) do
    {
      param: { my_resolver: 2 }
    }
  end
  let(:config) { double }
  let(:region) { 'us-east-1' }
  let(:my_resolver) {
    Class.new do
      def initialize(config, region)
      end

      def resolve(value)
        value.to_i * 5
      end
    end
  }

  before do
    stub_const('StackMaster::ParameterResolvers::MyResolver', my_resolver)
  end

  def resolve(params)
    StackMaster::ParameterResolver.resolve(config, 'us-east-1', params)
  end

  it 'returns the same value for strings' do
    expect(resolve(param1: 'value1')).to eq(param1: 'value1')
  end

  it 'it throws an error when the hash contains more than one key' do
    expect {
      resolve(param: { nested1: 'value1', nested2: 'value2' })
    }.to raise_error(StackMaster::ParameterResolver::InvalidParameter)
  end

  it 'throws an error when given an array' do
    expect {
      resolve(param: [1, 2])
    }.to raise_error(StackMaster::ParameterResolver::InvalidParameter)
  end

  context 'when given a proper resolve hash' do
    it 'returns the value returned by the resolver as the parameter value' do
      expect(resolve(param: { my_resolver: 2 })).to eq(param: 10)
    end
  end

  context 'when the resolver is unknown' do
    it 'throws an error' do
      expect {
        resolve(param: { my_unknown_resolver: 2 })
      }.to raise_error StackMaster::ParameterResolver::ResolverNotFound
    end
  end

  context 'resolver class caching' do
    it "uses the same instance of the resolver for the duration of the resolve run" do
      expect(my_resolver).to receive(:new).once.and_call_original
      expect(resolve(param: { my_resolver: 2 }, param2: { my_resolver: 2 })).to eq(param: 10, param2: 10)
    end
  end

  context 'when the resolver class already exist' do
    it 'does not try to load it' do
      expect(parameter_resolver).to receive(:load_parameter_resolver).once.and_call_original
      expect(parameter_resolver).not_to receive(:require_parameter_resolver)

      parameter_resolver.resolve
    end
  end

  context 'when the resolver class does not exist' do
    let(:params) do
      {
        param: { dummy_resolver: 2 }
      }
    end

    it 'tries to load it' do
      expect(parameter_resolver).to receive(:load_parameter_resolver).once.and_call_original
      expect(parameter_resolver).to receive(:require_parameter_resolver).and_return nil
      expect(parameter_resolver).to receive(:call_resolver).and_return nil

      parameter_resolver.resolve
    end
  end
end
