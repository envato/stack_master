RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do

  let(:sparkle_template) { instance_double(::SparkleFormation) }
  let(:sparkle_double) { instance_double(::SparkleFormation::SparkleCollection) }
  let(:compile_time_parameter_definitions) { {} }

  before do
    allow(sparkle_template).to receive(:sparkle).and_return(sparkle_double)
    allow(sparkle_template).to receive(:parameters).and_return(compile_time_parameter_definitions)
    allow(sparkle_template).to receive(:compile_time_parameter_setter).and_yield
    allow(sparkle_template).to receive(:compile_state=)
    allow(sparkle_template).to receive(:to_json).and_return("{\n}")
    allow(sparkle_double).to receive(:apply)
  end

  describe '.compile' do
    def compile
      described_class.compile(stack_definition, compile_time_parameters, compiler_options)
    end

    let(:stack_definition) {
      instance_double(StackMaster::StackDefinition,
        template_file_path: template_file_path,
        template_dir: File.dirname(template_file_path),
        sparkle_pack_template: nil)
    }
    let(:template_file_path) { '/base_dir/templates/template.rb' }
    let(:compile_time_parameters) { {'Ip' => '10.0.0.0', 'Name' => 'Something'} }
    let(:compiler_options) { {} }

    let(:definitions_validator) { instance_double(StackMaster::SparkleFormation::CompileTime::DefinitionsValidator) }
    let(:parameters_validator) { instance_double(StackMaster::SparkleFormation::CompileTime::ParametersValidator) }
    let(:state_builder) { instance_double(StackMaster::SparkleFormation::CompileTime::StateBuilder) }

    before do
      allow(::SparkleFormation).to receive(:compile).with(template_file_path, :sparkle).and_return(sparkle_template)
      allow(::SparkleFormation::Sparkle).to receive(:new)
      allow(StackMaster::SparkleFormation::CompileTime::DefinitionsValidator).to receive(:new).and_return(definitions_validator)
      allow(StackMaster::SparkleFormation::CompileTime::ParametersValidator).to receive(:new).and_return(parameters_validator)
      allow(StackMaster::SparkleFormation::CompileTime::StateBuilder).to receive(:new).and_return(state_builder)
      allow(::SparkleFormation::SparkleCollection).to receive(:new).and_return(sparkle_double)

      allow(sparkle_double).to receive(:set_root)
      allow(definitions_validator).to receive(:validate)
      allow(parameters_validator).to receive(:validate)
      allow(state_builder).to receive(:build).and_return({})
    end

    it 'compiles with sparkleformation' do
      expect(compile).to eq("{\n}")
    end

    it 'sets the appropriate sparkle_path' do
      compile
      expect(::SparkleFormation.sparkle_path).to eq File.dirname(template_file_path)
    end

    it 'should validate the compile time definitions' do
      expect(StackMaster::SparkleFormation::CompileTime::DefinitionsValidator).to receive(:new).with(compile_time_parameter_definitions)
      expect(definitions_validator).to receive(:validate)
      compile
    end

    it 'should validate the parameters against any compile time definitions' do
      expect(StackMaster::SparkleFormation::CompileTime::ParametersValidator).to receive(:new).with(compile_time_parameter_definitions, compile_time_parameters)
      expect(parameters_validator).to receive(:validate)
      compile
    end

    it 'should create the compile state' do
      expect(StackMaster::SparkleFormation::CompileTime::StateBuilder).to receive(:new).with(compile_time_parameter_definitions, compile_time_parameters)
      expect(state_builder).to receive(:build)
      compile
    end

    it 'should set the compile state' do
      expect(sparkle_template).to receive(:compile_state=).with({})
      compile
    end

    context 'with a custom sparkle_path' do
      let(:compiler_options) { {'sparkle_path' => '../foo'} }

      it 'does not use the default path' do
        compile
        expect(::SparkleFormation.sparkle_path).to_not eq File.dirname(template_file_path)
      end

      it 'expands the given path' do
        compile
        expect(::SparkleFormation.sparkle_path).to match %r{^([A-Z]{1}:)?[\/]+.+[\/]foo}
      end
    end

  end

  describe '.compile with sparkle packs' do
    let(:compile_time_parameters) { {} }
    let(:compiler_options) { {} }
    let(:stack_definition) {
      instance_double(StackMaster::StackDefinition,
        template_file_path: template_file_path,
        template_dir: File.dirname(template_file_path),
        sparkle_pack_template: nil)
    }
    subject(:compile) { described_class.compile(stack_definition, compile_time_parameters, compiler_options)}

    context 'with a sparkle_pack loaded' do
      let(:template_file_path) { File.join(File.dirname(__FILE__), "..", "..", "fixtures", "sparkle_pack_integration", "templates", "template_with_dynamic_from_pack.rb")}
      let(:compiler_options) { {"sparkle_packs" => ["my_sparkle_pack"]} }

      before do
        lib =  File.join(File.dirname(__FILE__), "..", "..", "fixtures", "sparkle_pack_integration", "my_sparkle_pack", "lib")
        puts "Loading from #{lib}"
        $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
      end

      it 'pulls the dynamic from the sparkle pack' do
        expect(compile).to eq(%Q({\n  \"Outputs\": {\n    \"Foo\": {\n      \"Value\": \"bar\"\n    }\n  }\n}))
      end
    end

    context 'when using sparkle pack template' do
      let(:template_name) { "foobar_template" }
      let(:stack_definition) do
        instance_double(StackMaster::StackDefinition,
          template_file_path: nil,
          template_dir: "/base_dir/templates",
          sparkle_pack_template: template_name)
      end
      let(:template_path) { "/base_dir/templates/#{template_name}.rb" }
      let(:pack_templates) do
        {'aws' => aws_templates}
      end
      let(:collection_double) { instance_double(::SparkleFormation::SparkleCollection, templates: pack_templates) }
      let(:root_pack) { instance_double(::SparkleFormation::Sparkle, "root_pack") }

      before do
        allow(::SparkleFormation::SparkleCollection).to receive(:new).and_return(collection_double)
        allow(collection_double).to receive(:set_root)
        allow(::SparkleFormation::Sparkle).to receive(:new).and_return(root_pack)
      end

      context 'when template is found' do
        let(:pack_template) { instance_double(::SparkleFormation::SparkleCollection::Rainbow, top: {'path' => template_path }) }
        let(:aws_templates) { {template_name => pack_template} }
        it 'resolves template location' do
          expect(::SparkleFormation).to receive(:compile).with(template_path, :sparkle).and_return(sparkle_template)
          expect(compile).to eq("{\n}")
        end
      end
      context 'when template is not found' do
        let(:aws_templates) { {} }
        it 'resolves template location' do
          expect { compile }.to raise_error(/not found in any sparkle pack/)
        end
      end
    end

    context 'without a sparkle_pack loaded' do
      let(:template_file_path) { File.join(File.dirname(__FILE__), "..", "..", "fixtures", "sparkle_pack_integration", "templates", "template_with_dynamic.rb")}

      it 'pulls the dynamic from the local path' do
        expect(compile).to eq(%Q({\n  \"Outputs\": {\n    \"Bar\": {\n      \"Value\": \"local_dynamic\"\n    }\n  }\n}))
      end
    end
  end
end
