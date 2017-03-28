RSpec.describe StackMaster::TemplateCompilers::Cfndsl do
  before(:all) { described_class.require_dependencies }

  describe '.compile' do
    def compile
      described_class.compile(template_file_path, compiler_options)
    end

    context 'valid cfndsl template' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample.json' }
      let(:compiler_options) { {} }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end
    end

    context 'with external_parameters' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample.rb' }
      let(:compiler_options)  { { "external_parameters" => 'foo/bar.yml' } }

      it 'tells CfnDsl to use an external parameter file' do
        expect(CfnDsl).to receive(:eval_file_with_extras).with(anything, ['foo/bar.yml'])
        compile
      end

      it 'disables bindings' do
        expect(::CfnDsl).to receive(:disable_binding)
        compile
      end
    end
  end
end
