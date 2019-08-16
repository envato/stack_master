RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do
  before(:all) { StackMaster::TemplateCompilers::SparkleFormation.require_dependencies }
  let(:compile_time_parameter_definitions) { {} }

  def project_path(path)
    File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", path))
  end

  def fixture_template(file)
    project_path("#{template_dir}/#{file}")
  end

  def template_dir
    "spec/fixtures/templates/rb/sparkle_formation/templates"
  end

  def sparkle_pack_dir
    project_path("spec/fixtures/sparkle_pack_integration/my_sparkle_pack/lib/sparkleformation/templates")
  end

  def sparkle_pack_template(file)
    project_path("#{sparkle_pack_dir}/#{file}")
  end

  describe '.compile' do
    def compile
      described_class.compile(template_dir, template, compile_time_parameters, compiler_options)
    end

    let(:stack_definition) {
      instance_double(StackMaster::StackDefinition,
        template: template,
        template_dir: template_dir)
    }
    let(:compile_time_parameters) { {'Ip' => '10.0.0.0', 'Name' => 'Something'} }
    let(:compiler_options) { {} }
    let(:template) { 'template.rb' }

    context 'without sparkle packs' do
      it 'compiles with sparkleformation' do
        expect(compile).to eq("{\n  \"Description\": \"A test VPC template\",\n  \"Resources\": {\n    \"Vpc\": {\n      \"Type\": \"AWS::EC2::VPC\",\n      \"Properties\": {\n        \"CidrBlock\": \"10.200.0.0/16\"\n      }\n    }\n  }\n}")
      end

      it 'sets the appropriate sparkle_path' do
        compile
        expect(::SparkleFormation.sparkle_path).to eq template_dir
      end

      context 'compile time parameters validations' do
        it 'should validate the compile time definitions' do
          definitions_validator = double
          expect(StackMaster::SparkleFormation::CompileTime::DefinitionsValidator).to receive(:new).with(compile_time_parameter_definitions).and_return(definitions_validator)
          expect(definitions_validator).to receive(:validate)
          compile
        end

        it 'should validate the parameters against any compile time definitions' do
          parameters_validator = double
          expect(StackMaster::SparkleFormation::CompileTime::ParametersValidator).to receive(:new).with(compile_time_parameter_definitions, compile_time_parameters).and_return(parameters_validator)
          expect(parameters_validator).to receive(:validate)
          compile
        end

        it 'should create the compile state' do
          state_builder = double
          expect(StackMaster::SparkleFormation::CompileTime::StateBuilder).to receive(:new).with(compile_time_parameter_definitions, compile_time_parameters).and_return(state_builder)
          expect(state_builder).to receive(:build)
          compile
        end

        xit 'should set the compile state' do
          expect(sparkle_template).to receive(:compile_state=).with({})
          compile
        end
      end
    end

    context 'with a custom sparkle_path' do
      let(:compiler_options) { {'sparkle_path' => sparkle_pack_dir} }

      it 'expands the given path' do
        compile
        expect(::SparkleFormation.sparkle_path).to match sparkle_pack_dir
      end
    end

    context 'with sparkle packs' do
      let(:compile_time_parameters) { {} }
      let(:compiler_options) { {"sparkle_packs" => ["my_sparkle_pack"]} }

      before do
        lib = File.join(File.dirname(__FILE__), "..", "..", "fixtures", "sparkle_pack_integration", "my_sparkle_pack", "lib")
        $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
      end

      context 'compiling a sparkle pack dynamic' do
        let(:template) { 'template_with_dynamic_from_pack' }
        let(:compiler_options) { {"sparkle_packs" => ["my_sparkle_pack"], "sparkle_pack_template" => true} }

        it 'pulls the dynamic from the sparkle pack' do
          expect(compile).to eq(%Q({\n  \"Outputs\": {\n    \"Foo\": {\n      \"Value\": \"bar\"\n    }\n  }\n}))
        end
      end

      context 'compiling a sparkle pack template' do
        let(:template) { 'template_with_dynamic' }
        let(:compiler_options) { {"sparkle_packs" => ["my_sparkle_pack"], "sparkle_pack_template" => true} }

        context 'when template is found' do
          it 'resolves template location' do
            expect(compile).to eq("{\n  \"Outputs\": {\n    \"Bar\": {\n      \"Value\": \"local_dynamic\"\n    }\n  }\n}")
          end
        end

        context 'when template is not found' do
          let(:template) { 'non_existant_template' }

          it 'resolves template location' do
            expect { compile }.to raise_error(/not found in any sparkle pack/)
          end
        end
      end
    end
  end
end
