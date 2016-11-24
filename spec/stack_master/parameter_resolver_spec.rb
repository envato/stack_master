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
  let(:bad_resolver) {
    Class.new do
      def initialize(config, region)
      end

      def resolve(value)
        raise Aws::CloudFormation::Errors::ValidationError.new(nil, "Can't find stack")
      end
    end
  }

  before do
    stub_const('StackMaster::ParameterResolvers::MyResolver', my_resolver)
    stub_const('StackMaster::ParameterResolvers::BadResolver', bad_resolver)
  end

  def resolve(params)
    StackMaster::ParameterResolver.resolve(config, 'us-east-1', params)
  end

  it 'returns the same value for strings' do
    expect(resolve(param1: 'value1')).to eq(param1: 'value1')
  end

  it 'returns integers as strings' do
    expect(resolve(param1: 2)).to eq(param1: '2')
  end

  it 'joins arrays into comma separated strings' do
    expect(resolve(param1: [1, 2])).to eq(param1: '1,2')
  end

  it 'converts boolean values to strings' do
    expect(resolve(param1: true)).to eq(param1: 'true')
    expect(resolve(param1: false)).to eq(param1: 'false')
  end

  it 'it throws an error when the hash contains more than one key' do
    expect {
      resolve(param: { nested1: 'value1', nested2: 'value2' })
    }.to raise_error(StackMaster::ParameterResolver::InvalidParameter)
  end

  it "doesn't throw an error when given an array" do
    expect {
      resolve(param: [1, 2])
    }.to_not raise_error
  end

  context 'when array values contain resolver hashes' do
    it 'returns the comma separated string values returned by the resolvers' do
      expect(resolve(param: [1, { my_resolver: 2 }])).to eq(param: '1,10')
    end

    it 'returns nested array values' do
      expect(resolve(param: [[1, { my_resolver: 3 }], { my_resolver: 2 }])).to eq(param: '1,15,10')
    end
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

  context 'when the resolver throws a ValidationError' do
    it 'throws a invalid parameter error' do
      expect {
        resolve(param: { bad_resolver: 2 })
      }.to raise_error StackMaster::ParameterResolver::InvalidParameter
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

    context "using an array resolver" do
      let(:params) do
        {
          param: { other_dummy_resolvers: [1, 2] }
        }
      end

      it "tries to load the plural and singular forms" do
        expect(parameter_resolver).to receive(:require_parameter_resolver).with("other_dummy_resolvers").once.and_call_original.ordered
        expect(parameter_resolver).to receive(:require_parameter_resolver).with("other_dummy_resolver").once.ordered
        expect(parameter_resolver).to receive(:call_resolver).and_return nil

        parameter_resolver.resolve
      end
    end
  end
end
