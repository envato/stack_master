RSpec.describe StackMaster::Commands::Nag do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: region, stack_name: stack_name) }
  let(:config) { double(find_stack: stack_definition) }
  let(:parameters) { {} }
  let(:proposed_stack) {
    StackMaster::Stack.new(
      template_body: template_body,
      template_format: template_format,
      parameters: parameters)
  }
  let(:tempfile) { double(:tempfile) }
  let(:path) { double(:path) }

  before do
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
  end

  def run
    described_class.perform(config, stack_definition)
  end

  context "with a json stack" do
    let(:template_body) { '{}' }
    let(:template_format) { :json }

    it 'outputs the template' do
      expect_any_instance_of(described_class).to receive(:system).once.with('cfn_nag', /.*\.json/)
      run
    end
  end

  context "with a yaml stack" do
    let(:template_body) { '---' }
    let(:template_format) { :yaml }

    it 'outputs an error' do
      expect { run }.to output(/cfn_nag doesn't support yaml formatted templates/).to_stderr
    end
  end
end
