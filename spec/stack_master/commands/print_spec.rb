RSpec.describe StackMaster::Commands::Print do
  subject(:print) { described_class.new(config, stack_definition) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'mystack' }
  let(:stack_definition) { double(:stack_definition, template_file_path: '/base_dir/templates/template.json', compiler_options: {}) }
  let(:config) { instance_double(StackMaster::Config, stacks: [stack_definition]) }

  describe "#perform" do
    it 'Prints the compiled template' do
      expect(StackMaster::TemplateCompiler).to receive(:compile).with(config, '/base_dir/templates/template.json', nil, {}).and_return('{ }')
      expect(StackMaster.stdout).to receive(:puts).with('{ }')
      print.perform
    end
  end
end
