RSpec.describe StackMaster::Commands::Print do
  subject(:print) { described_class.new(config, stack_definition) }
  let(:stack_definition) { double(:stack_definition, template_file_path: '/base_dir/templates/template.json', compiler_options: {}, parameter_files: ['/base_dir/parameters/stack.yml']) }
  let(:config) { instance_double(StackMaster::Config, stacks: [stack_definition]) }

  describe "#perform" do
    it 'Prints the compiled template' do
      expect(StackMaster::ParameterLoader).to receive(:load).with(['/base_dir/parameters/stack.yml']).and_return(compile_time_parameters: { 'foo' => 'bar' })
      expect(StackMaster::ParameterResolver).to receive(:resolve).with(config, stack_definition, { 'foo' => 'bar' }).and_return('foo' => 'bar')
      expect(StackMaster::TemplateCompiler).to receive(:compile).with(config, '/base_dir/templates/template.json', { 'foo' => 'bar' }, {}).and_return('{ }')
      expect(StackMaster.stdout).to receive(:puts).with('{ }')
      print.perform
    end
  end
end
