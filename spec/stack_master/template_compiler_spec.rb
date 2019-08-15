RSpec.describe StackMaster::TemplateCompiler do
  describe '.compile' do
    let(:config) { double(template_compilers: { fab: :test_template_compiler, rb: :test_template_compiler }) }
    let(:stack_definition) {
      instance_double(StackMaster::StackDefinition,
        template_file_path: '/base_dir/templates/template.fab',
        sparkle_pack_template: nil)
    }
    let(:compile_time_parameters) { { 'InstanceType' => 't2.medium' } }

    class TestTemplateCompiler
      def self.require_dependencies; end
      def self.compile(stack_definition, compile_time_parameters, compile_options); end
    end

    context 'when a template compiler is registered for the given file type' do
      before {
        StackMaster::TemplateCompiler.register(:test_template_compiler, TestTemplateCompiler)
      }

      it 'compiles the template using the relevant template compiler' do
        expect(TestTemplateCompiler).to receive(:compile).with(stack_definition, compile_time_parameters, anything)
        StackMaster::TemplateCompiler.compile(config, stack_definition, compile_time_parameters, compile_time_parameters)
      end

      it 'passes compile_options to the template compiler' do
        opts = {foo: 1, bar: true, baz: "meh"}
        expect(TestTemplateCompiler).to receive(:compile).with(stack_definition, compile_time_parameters, opts)
        StackMaster::TemplateCompiler.compile(config, stack_definition, compile_time_parameters,opts)
      end

      context 'when template compilation fails' do
        before { allow(TestTemplateCompiler).to receive(:compile).and_raise(RuntimeError) }

        it 'raise TemplateCompilationFailed exception' do
          expect{ StackMaster::TemplateCompiler.compile(config, stack_definition, compile_time_parameters, compile_time_parameters)
          }.to raise_error(
                 StackMaster::TemplateCompiler::TemplateCompilationFailed, /^Failed to compile #{stack_definition.template_file_path}/)
        end
      end
    end

    context 'when a sparkle pack template is being requested' do
      let(:stack_definition) {
        instance_double(StackMaster::StackDefinition,
          sparkle_pack_template: 'foobar')
      }

      before {
        StackMaster::TemplateCompiler.register(:test_template_compiler, TestTemplateCompiler)
      }

      it 'compiles the template using the sparkle pack compiler' do
        expect(TestTemplateCompiler).to receive(:compile).with(stack_definition, compile_time_parameters, anything)
        StackMaster::TemplateCompiler.compile(config, stack_definition, compile_time_parameters, compile_time_parameters)
      end
    end
  end
end
