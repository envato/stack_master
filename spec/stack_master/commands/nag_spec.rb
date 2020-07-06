RSpec.describe StackMaster::Commands::Nag do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: region, stack_name: stack_name) }
  let(:config) { instance_double(StackMaster::Config, find_stack: stack_definition) }
  let(:parameters) { {} }
  let(:proposed_stack) {
    StackMaster::Stack.new(
      template_body: template_body,
      template_format: template_format,
      parameters: parameters)
  }
  let(:tempfile) { double(Tempfile) }
  let(:path) { double(String) }

  before do
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
  end

  def run
    described_class.perform(config, stack_definition)
  end

  context "with a json stack" do
    let(:template_body) { '{}' }
    let(:template_format) { :json }

    it 'calls the nag gem' do
      expect_any_instance_of(File).to receive(:write).once
      expect_any_instance_of(File).to receive(:flush).once
      expect_any_instance_of(described_class).to receive(:system).once.with('cfn_nag', /.*\.json/)
      run
    end
  end

  context "with a yaml stack" do
    let(:template_body) { '---' }
    let(:template_format) { :yaml }

    it 'calls the nag gem' do
      expect_any_instance_of(File).to receive(:write).once
      expect_any_instance_of(File).to receive(:flush).once
      expect_any_instance_of(described_class).to receive(:system).once.with('cfn_nag', /.*\.yaml/)
      run
    end
  end
end
