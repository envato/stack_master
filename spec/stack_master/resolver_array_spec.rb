require 'stack_master/resolver_array'

RSpec.shared_examples_for 'a resolver' do
  it 'should create a TestResolvers class' do
    expect(array_resolver_class).to be_a Class
  end

  it 'should have TestResolver as a resolver class' do
    expect(array_resolver_instance).to respond_to :resolver_class
    expect(array_resolver_instance.resolver_class).to be TestResolver
  end
end

RSpec.describe 'StackMaster::ParameterResolvers::Resolver' do
  let(:array_resolver_instance) { array_resolver_class.new(nil, nil) }

  describe '.array_resolver' do
    context 'when using a default name' do
      before do
        class TestResolver < StackMaster::ParameterResolvers::Resolver
          array_resolver
        end
      end

      let(:array_resolver_class) { StackMaster::ParameterResolvers::TestResolvers }

      it_behaves_like 'a resolver'
    end

    context 'when using a specific name' do
      before do
        class TestResolver < StackMaster::ParameterResolvers::Resolver
          array_resolver class_name: 'SpecificResolver'
        end
      end

      let(:array_resolver_class) { StackMaster::ParameterResolvers::SpecificResolver }

      it_behaves_like 'a resolver'
    end
  end
end
