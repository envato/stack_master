RSpec.describe StackMaster::ParameterResolver do
  subject(:parameter_resolver) { StackMaster::ParameterResolver.new(config, region, params) }
  let(:params) do
    {
      param: { my_resolver: 2 }
    }
  end
  let(:config) { double }
  let(:region) { 'us-east-1' }
  let(:my_resolver) do
    Class.new do
      def initialize(config, region)
      end

      def resolve(value)
        value.to_i * 5
      end
    end
  end
  let(:bad_resolver) do
    Class.new do
      def initialize(config, region)
      end

      def resolve(value)
        raise Aws::CloudFormation::Errors::ValidationError.new(nil, "Can't find stack")
      end
    end
  end

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
    expect do
      resolve(param: { nested1: 'value1', nested2: 'value2' })
    end.to raise_error(StackMaster::ParameterResolver::InvalidParameter)
  end

  it "doesn't throw an error when given an array" do
    expect do
      resolve(param: [1, 2])
    end.to_not raise_error
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
      expect do
        resolve(param: { my_unknown_resolver: 2 })
      end.to raise_error StackMaster::ParameterResolver::ResolverNotFound
    end
  end

  context 'when the resolver throws a ValidationError' do
    it 'throws a invalid parameter error' do
      expect do
        resolve(param: { bad_resolver: 2 })
      end.to raise_error StackMaster::ParameterResolver::InvalidParameter
    end
  end

  context 'when assuming a role' do
    let(:role_assumer) { instance_double(StackMaster::RoleAssumer, assume_role: nil) }
    let(:account) { '1234567890' }
    let(:role) { 'my-role' }

    before do
      allow(StackMaster::RoleAssumer).to receive(:new).and_return(role_assumer)
    end

    context 'with valid assume role properties' do
      let(:params) do
        {
          param: {
            'account' => account,
            'role' => role,
            'my_resolver' => 2
          }
        }
      end

      it 'assumes the role' do
        expect(StackMaster::RoleAssumer).to receive(:new)
        expect(role_assumer).to receive(:assume_role).with(account, role)

        parameter_resolver.resolve
      end
    end

    context 'when multiple params assume roles' do
      let(:params) do
        {
          param: {
            'account' => account,
            'role' => role,
            'my_resolver' => 1
          },
          param2: {
            'account' => account,
            'role' => 'different-role',
            'my_resolver' => 2
          }
        }
      end

      it 'caches the role assumer' do
        expect(StackMaster::RoleAssumer).to receive(:new).once

        parameter_resolver.resolve
      end

      it 'calls assume role once for every param' do
        expect(role_assumer).to receive(:assume_role).with(account, role).once
        expect(role_assumer).to receive(:assume_role).with(account, 'different-role').once

        parameter_resolver.resolve
      end
    end

    context 'with missing assume role properties' do
      it 'does not assume a role' do
        expect(StackMaster::RoleAssumer).not_to receive(:new)

        parameter_resolver.resolve
      end
    end

    context "with missing 'account' property" do
      it 'raises an invalid parameter error' do
        expect do
          resolve(param: { 'role' => role, 'my_resolver' => 2 })
        end.to raise_error StackMaster::ParameterResolver::InvalidParameter,
                           match("Both 'account' and 'role' are required to assume role for parameter 'param'")
      end
    end

    context "with missing 'role' property" do
      it 'raises an invalid parameter error' do
        expect do
          resolve(param: { 'account' => account, 'my_resolver' => 2 })
        end.to raise_error StackMaster::ParameterResolver::InvalidParameter,
                           match("Both 'account' and 'role' are required to assume role for parameter 'param'")
      end
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
        expect(parameter_resolver)
          .to receive(:require_parameter_resolver)
          .with("other_dummy_resolvers")
          .once
          .and_call_original
          .ordered
        expect(parameter_resolver)
          .to receive(:require_parameter_resolver)
          .with("other_dummy_resolver")
          .once
          .ordered
        expect(parameter_resolver)
          .to receive(:call_resolver)
          .and_return nil

        parameter_resolver.resolve
      end
    end
  end
end
