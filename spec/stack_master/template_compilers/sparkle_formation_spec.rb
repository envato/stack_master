require 'sparkle_formation'
RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do

  describe '.compile' do
    def compile
      described_class.compile(template_file_path, parameters, compiler_options)
    end

    let(:template_file_path) {'/base_dir/templates/template.rb'}
    let(:parameters){{'Ip' => '10.0.0.0', 'Name' => 'Something'}}
    let(:compiler_options) {{}}
    let(:compile_time_parameter_definitions) {{}}

    let(:sparkle_template) {instance_double(::SparkleFormation)}
    let(:definitions_validator){instance_double(StackMaster::SparkleFormation::CompileTime::DefinitionsValidator)}
    let(:parameters_validator){instance_double(StackMaster::SparkleFormation::CompileTime::ParametersValidator)}
    let(:state_builder){instance_double(StackMaster::SparkleFormation::CompileTime::StateBuilder)}

    before do
      allow(::SparkleFormation).to receive(:compile).with(template_file_path, :sparkle).and_return(sparkle_template)
      allow(StackMaster::SparkleFormation::CompileTime::DefinitionsValidator).to receive(:new).and_return(definitions_validator)
      allow(StackMaster::SparkleFormation::CompileTime::ParametersValidator).to receive(:new).and_return(parameters_validator)
      allow(StackMaster::SparkleFormation::CompileTime::StateBuilder).to receive(:new).and_return(state_builder)

      allow(sparkle_template).to receive(:parameters).and_return(compile_time_parameter_definitions)
      allow(definitions_validator).to receive(:validate)
      allow(parameters_validator).to receive(:validate)
      allow(state_builder).to receive(:build).and_return({})
      allow(sparkle_template).to receive(:compile_time_parameter_setter).and_yield
      allow(sparkle_template).to receive(:compile_state=)
      allow(sparkle_template).to receive(:to_json).and_return("{\n}")
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
      expect(StackMaster::SparkleFormation::CompileTime::ParametersValidator).to receive(:new).with(compile_time_parameter_definitions, parameters)
      expect(parameters_validator).to receive(:validate)
      compile
    end

    it 'should create the compile state' do
      expect(StackMaster::SparkleFormation::CompileTime::StateBuilder).to receive(:new).with(compile_time_parameter_definitions, parameters)
      expect(state_builder).to receive(:build)
      compile
    end

    it 'should set the compile state' do
      expect(sparkle_template).to receive(:compile_state=).with({})
      compile
    end

    context 'with compile time parameter definitions' do
      let(:compile_time_parameter_definitions) {{ip: {type: :string}}}

      it 'should remove the parameters that match the definition' do
        compile
        expect(parameters).to eq({'Name' => 'Something'})
      end

    end

    context 'with a custom sparkle_path' do
      let(:compiler_options) {{'sparkle_path' => '../foo'}}

      it 'does not use the default path' do
        compile
        expect(::SparkleFormation.sparkle_path).to_not eq File.dirname(template_file_path)
      end

      it 'expands the given path' do
        compile
        expect(::SparkleFormation.sparkle_path).to match %r{^/.+/foo}
      end
    end

  end

end
