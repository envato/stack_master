RSpec.describe StackMaster::ParameterResolvers::StackOutput do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'my-stack' }
  let(:resolver) { described_class.new(config, double(environment: 'prod', region: 'us-east-1')) }
  let(:cf) { Aws::CloudFormation::Client.new }
  let(:config) { double(:unalias_region => region) }

  def resolve(value)
    resolver.resolve(value)
  end

  subject(:resolved_value) { resolve(value) }

  context 'when given an invalid string value' do
    let(:value) { 'stack-name-without-output' }

    it 'raises an error' do
      expect {
        resolved_value
      }.to raise_error(ArgumentError)
    end
  end

  context 'when given a hash' do
    let(:value) { { not_expected: 1} }

    it 'raises an error' do
      expect {
        resolved_value
      }.to raise_error(ArgumentError)
    end
  end

  context 'when given a valid string value' do
    let(:value) { 'my-stack/MyOutput' }
    let(:stacks) { [{ stack_name: 'blah', creation_time: Time.now, stack_status: 'CREATE_COMPLETE', outputs: outputs}] }
    let(:outputs) { [] }

    before do
      allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
      cf.stub_responses(:describe_stacks, stacks: stacks)
    end

    context 'the stack and output exist' do
      let(:outputs) { [{output_key: 'MyOutput', output_value: 'myresolvedvalue'}] }

      it 'resolves the value' do
        expect(resolved_value).to eq 'myresolvedvalue'
      end

      it 'caches stacks for the lifetime of the instance' do
        resolver.resolve(value)
        resolver.resolve(value)
      end
    end

    context "the stack doesn't exist" do
      let(:stacks) { nil }

      it 'resolves the value' do
        expect {
          resolved_value
        }.to raise_error(StackMaster::ParameterResolvers::StackOutput::StackNotFound)
      end
    end

    context "the output doesn't exist" do
      let(:outputs) { [] }

      it 'resolves the value' do
        expect {
          resolved_value
        }.to raise_error(StackMaster::ParameterResolvers::StackOutput::StackOutputNotFound)
      end
    end
  end

  context 'when given a valid string value including region' do
    let(:value) { 'us-east-1:my-stack/MyOutput' }
    let(:stacks) { [{ stack_name: 'my-stack', creation_time: Time.now, stack_status: 'CREATE_COMPLETE', outputs: outputs}] }
    let(:outputs) { [] }

    before do
      allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
      cf.stub_responses(:describe_stacks, stacks: stacks)
    end

    context 'the stack and output exist' do
      let(:outputs) { [{output_key: 'MyOutput', output_value: 'myresolvedvalue'}] }

      it 'resolves the value' do
        expect(resolved_value).to eq 'myresolvedvalue'
      end

      context 'the stack and output exist in a different region with the same name' do
        let(:value_in_region_alias) { 'global:my-stack/MyOutput' }
        let(:value_in_region_2) { 'ap-southeast-2:my-stack/MyOutput' }
        let(:outputs_in_region_2) { [{output_key: 'MyOutput', output_value: 'myresolvedvalue2'}] }
        let(:stacks_in_region_2) { [{ stack_name: 'my-stack', creation_time: Time.now, stack_status: 'CREATE_COMPLETE', outputs: outputs_in_region_2}] }

        before do
          cf.stub_responses(
            :describe_stacks,
            { stacks: stacks },
            { stacks: stacks_in_region_2 }
          )
          allow(config).to receive(:unalias_region) do |aliased_region|
            if aliased_region == 'global'
              'us-east-1'
            else
              aliased_region
            end
          end
        end

        it 'resolves the value to the right region' do
          resolver.resolve(value)
          expect(resolver.resolve(value_in_region_2)).to eq 'myresolvedvalue2'
        end

        it 'resolves to the same region if it is an alias' do
          expect(resolver.resolve(value_in_region_alias)).to eq 'myresolvedvalue'
        end
      end
    end
  end
end
