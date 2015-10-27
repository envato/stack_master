RSpec.describe StackMaster::ParameterResolver do
  def resolve(params)
    StackMaster::ParameterResolver.resolve('us-east-1', params)
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
    let(:my_resolver) {
      Class.new do
        def initialize(region, value)
          @value = value
        end

        def resolve
          @value.to_i * 5
        end
      end
    }

    before do
      stub_const('StackMaster::ParameterResolvers::MyResolver', my_resolver)
    end

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
end
