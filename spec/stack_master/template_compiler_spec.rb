RSpec.describe StackMaster::TemplateCompiler do
  describe '.compile' do
    let(:config) { double(template_compilers: { fab: :test_template_compiler, rb: :test_template_compiler }) }
    let(:template_file_path) { '/base_dir/templates/template.fab' }
    let(:template_dir) { File.dirname(template_file_path) }
    let(:stack_definition) {
      instance_double(StackMaster::StackDefinition,
        template_file_path: template_file_path,
        template_dir: template_dir,
        )
    }
    let(:compile_time_parameters) { { 'InstanceType' => 't2.medium' } }

    class TestTemplateCompiler
      def self.require_dependencies; end
      def self.compile(template_dir, template_file_path, compile_time_parameters, compile_options); end
    end

    context 'when a template compiler is registered for the given file type' do
      before {
        StackMaster::TemplateCompiler.register(:test_template_compiler, TestTemplateCompiler)
      }

      it 'compiles the template using the relevant template compiler' do
        expect(TestTemplateCompiler).to receive(:compile).with(nil, template_file_path, compile_time_parameters, anything)
        StackMaster::TemplateCompiler.compile(config, nil, template_file_path, compile_time_parameters, compile_time_parameters)
      end

      it 'passes compile_options to the template compiler' do
        opts = {foo: 1, bar: true, baz: "meh"}
        expect(TestTemplateCompiler).to receive(:compile).with(nil, template_file_path, compile_time_parameters, opts)
        StackMaster::TemplateCompiler.compile(config, nil, template_file_path, compile_time_parameters,opts)
      end

      context 'when template compilation fails' do
        before { allow(TestTemplateCompiler).to receive(:compile).and_raise(RuntimeError) }

        it 'raise TemplateCompilationFailed exception' do
          expect{ StackMaster::TemplateCompiler.compile(config, template_dir, template_file_path, compile_time_parameters, compile_time_parameters)
          }.to raise_error(
                 StackMaster::TemplateCompiler::TemplateCompilationFailed, /^Failed to compile #{stack_definition.template_file_path}/)
        end
      end
    end
  end
end
