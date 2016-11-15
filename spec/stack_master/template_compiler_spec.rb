RSpec.describe StackMaster::TemplateCompiler do
  describe '.compile' do
    let(:config) { double(template_compilers: { fab: :test_template_compiler }) }
    let(:template_file_path) { '/base_dir/templates/template.fab' }
    let(:stack_definition) do
      StackMaster::StackDefinition.new(
        region: 'us-east-1',
        stack_name: 'myapp_vpc',
        template: 'myapp_vpc.json',
        tags: { 'environment' => 'production' },
        base_dir: File.expand_path('spec/fixtures'),
      )
    end

    class TestTemplateCompiler
      def self.require_dependencies; end
      def self.compile(config, template_file_path, stack_definition); end
    end

    context 'when a template compiler is registered for the given file type' do
      before {
        StackMaster::TemplateCompiler.register(:test_template_compiler, TestTemplateCompiler)
      }

      it 'compiles the template using the relevant template compiler' do
        expect(TestTemplateCompiler).to receive(:compile).with(config, template_file_path, stack_definition)
        StackMaster::TemplateCompiler.compile(config, template_file_path, stack_definition)
      end

      context 'when template compilation fails' do
        before { allow(TestTemplateCompiler).to receive(:compile).and_raise(RuntimeError) }

        it 'raise TemplateCompilationFailed exception' do
          expect{ StackMaster::TemplateCompiler.compile(config, template_file_path, stack_definition)
          }.to raise_error(
                 StackMaster::TemplateCompiler::TemplateCompilationFailed,"Failed to compile #{template_file_path}.")
        end
      end
    end
  end
end
