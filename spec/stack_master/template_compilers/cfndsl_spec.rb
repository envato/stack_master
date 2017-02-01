RSpec.describe StackMaster::TemplateCompilers::Cfndsl do
  let(:config) { StackMaster::Config.new({'stacks' => {}}, '/base_dir') }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures'),
    )
  end
  before(:all) { described_class.require_dependencies }

  describe '.compile' do
    def compile
      described_class.compile(config, template_file_path, stack_definition.cfndsl_external_parameters)
    end

    context 'valid cfndsl template' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end
    end
  end
end
