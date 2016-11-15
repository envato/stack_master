RSpec.describe StackMaster::TemplateCompilers::Yaml do
  let(:config) { double(template_compilers: { fab: :test_template_compiler }) }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures'),
    )
  end

  describe '.compile' do
    def compile
      described_class.compile(config, template_file_path, stack_definition)
    end

    context 'valid YAML template' do
      let(:template_file_path) { 'spec/fixtures/templates/yml/valid_myapp_vpc.yml' }

      it 'produces valid YAML' do
        valid_myapp_vpc_yaml = File.read('spec/fixtures/templates/yml/valid_myapp_vpc.yml')

        expect(compile).to eq(valid_myapp_vpc_yaml)
      end
    end
  end
end
