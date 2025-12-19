RSpec.describe StackMaster::Commands::Compile do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp-vpc' }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: region, stack_name: stack_name) }
  let(:config) { double(find_stack: stack_definition) }
  let(:parameters) { {} }
  let(:proposed_stack) {
    StackMaster::Stack.new(
      template_body: template_body,
      template_format: template_format,
      parameters: parameters
    )
  }

  let(:template_body) { '{}' }
  let(:template_format) { :json }

  before do
    allow(StackMaster::Stack).to receive(:generate).with(stack_definition, config).and_return(proposed_stack)
  end

  def run
    described_class.perform(config, stack_definition)
  end

  context "with a json stack" do
    it 'outputs the template' do
      expect { run }.to output(template_body + "\n").to_stdout
    end
  end

  context "with a yaml stack" do
    let(:template_body) { '---' }
    let(:template_format) { :yaml }

    it 'outputs the template' do
      expect { run }.to output(template_body + "\n").to_stdout
    end
  end
end
