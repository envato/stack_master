RSpec.describe StackMaster::TemplateCompiler do
  describe '.compile' do
    let(:config) { double(template_compilers: { fab: :test_template_compiler, rb: :test_template_compiler }) }
    let(:template) { 'template.fab' }
    let(:template_dir) { '/base_dir/templates' }
    let(:compile_time_parameters) { { 'InstanceType' => 't2.medium' } }

    class TestTemplateCompiler
      def self.require_dependencies; end
      def self.compile(template_dir, template, compile_time_parameters, compile_options); end
    end

    context 'when a template compiler is explicitly specified' do
      it 'uses it' do
        expect(StackMaster::TemplateCompilers::SparkleFormation).to receive(:compile).with('/base_dir/templates', 'template', compile_time_parameters, anything)
        StackMaster::TemplateCompiler.compile(config, :sparkle_formation, '/base_dir/templates', 'template', compile_time_parameters, compile_time_parameters)
      end
    end

    context 'when a template compiler is registered for the given file type' do
      before {
        StackMaster::TemplateCompiler.register(:test_template_compiler, TestTemplateCompiler)
      }

      it 'compiles the template using the relevant template compiler' do
        expect(TestTemplateCompiler).to receive(:compile).with(nil, template, compile_time_parameters, anything)
        StackMaster::TemplateCompiler.compile(config, nil, nil, template, compile_time_parameters, compile_time_parameters)
      end

      it 'passes compile_options to the template compiler' do
        opts = {foo: 1, bar: true, baz: "meh"}
        expect(TestTemplateCompiler).to receive(:compile).with(nil, template, compile_time_parameters, opts)
        StackMaster::TemplateCompiler.compile(config, nil, nil, template, compile_time_parameters,opts)
      end

      context 'when template compilation fails' do
        before { allow(TestTemplateCompiler).to receive(:compile).and_raise(RuntimeError) }

        it 'raise TemplateCompilationFailed exception' do
          expect{ StackMaster::TemplateCompiler.compile(config, nil, template_dir, template, compile_time_parameters, compile_time_parameters)
          }.to raise_error(
                 StackMaster::TemplateCompiler::TemplateCompilationFailed, /^Failed to compile/)
        end
      end
    end
  end
end
