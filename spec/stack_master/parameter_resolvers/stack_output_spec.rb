RSpec.describe StackMaster::ParameterResolvers::StackOutput do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'my-stack' }
  let(:resolver) { described_class.new(config, double(region: 'us-east-1')) }
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
      cf.stub_responses(:describe_stacks, { stacks: stacks })
    end

    context 'the stack and output exist' do
      let(:outputs) { [{output_key: 'MyOutput', output_value: 'myresolvedvalue'}] }

      before do
        allow(config).to receive(:unalias_region).with('ap-southeast-2').and_return('ap-southeast-2')
      end

      it 'resolves the value' do
        expect(resolved_value).to eq 'myresolvedvalue'
      end

      it 'caches stacks for the lifetime of the instance' do
        expect(cf).to receive(:describe_stacks).with({ stack_name: 'my-stack' }).and_call_original.once
        resolver.resolve(value)
        resolver.resolve(value)
      end

      it "caches stacks by region" do
        expect(cf).to receive(:describe_stacks).with({ stack_name: 'my-stack' }).and_call_original.twice
        resolver.resolve(value)
        resolver.resolve(value)
        resolver.resolve("ap-southeast-2:#{value}")
        resolver.resolve("ap-southeast-2:#{value}")
      end

      context "when different credentials are used" do
        let(:outputs_in_account_2) { [ {output_key: 'MyOutput', output_value: 'resolvedvalueinaccount2'} ] }
        let(:stacks_in_account_2) { [{ stack_name: 'other-stack', creation_time: Time.now, stack_status: 'CREATE_COMPLETE', outputs: outputs_in_account_2}] }

        before do
          cf.stub_responses(
            :describe_stacks,
            { stacks: stacks },
            { stacks: stacks_in_account_2 }
          )
        end

        it "caches stacks by credentials" do
          expect(cf).to receive(:describe_stacks).with({ stack_name: 'my-stack' }).and_call_original.twice
          resolver.resolve(value)
          resolver.resolve(value)
          Aws.config[:credentials] = "my-credentials"
          resolver.resolve(value)
          resolver.resolve(value)
          Aws.config.delete(:credentials)
        end

        it "caches CF clients by region and credentials" do
          expect(Aws::CloudFormation::Client).to receive(:new).and_return(cf).exactly(3).times
          resolver.resolve(value)
          resolver.resolve(value)
          resolver.resolve('other-stack/MyOutput')
          resolver.resolve('other-stack/MyOutput')
          Aws.config[:credentials] = "my-credentials"
          resolver.resolve('other-stack/MyOutput')
          resolver.resolve('other-stack/MyOutput')
          resolver.resolve('ap-southeast-2:other-stack/MyOutput')
          resolver.resolve('ap-southeast-2:other-stack/MyOutput')
          Aws.config.delete(:credentials)
        end
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
      cf.stub_responses(:describe_stacks, { stacks: stacks })
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
