RSpec.describe StackMaster::Validator do

  subject(:validator) { described_class.new(stack_definition, config, options) }
  let(:config) { StackMaster::Config.new({'stacks' => {}}, '/base_dir') }
  let(:options) { Commander::Command::Options.new }
  let(:stack_name) { 'myapp_vpc' }
  let(:template_file) { 'myapp_vpc.json' }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      stack_name: stack_name,
      template: template_file,
      tags: {'environment' => 'production'},
      base_dir: File.expand_path('spec/fixtures'),
    )
  end
  let(:cf) { spy(Aws::CloudFormation::Client, validate_template: nil) }
  let(:parameter_hash) { {template_parameters: {}, compile_time_parameters: {'DbPassword' => {'secret' => 'db_password'}}} }
  let(:resolved_parameters) { {'DbPassword' => 'sdfgjkdhlfjkghdflkjghdflkjg', 'InstanceType' => 't2.medium'} }
  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return cf
    allow(StackMaster::ParameterLoader).to receive(:load).and_return(parameter_hash)
    allow(StackMaster::ParameterResolver).to receive(:resolve).and_return(resolved_parameters)
  end

  describe "#perform" do
    context "template body is valid" do
      it "tells the user everything will be fine" do
        expect { validator.perform }.to output(/myapp_vpc: valid/).to_stdout
      end
    end

    context "invalid template body" do
      before do
        allow(cf).to receive(:validate_template).and_raise(Aws::CloudFormation::Errors::ValidationError.new('a', 'Problem'))
      end

      it "informs the user of their stupdity" do
        expect { validator.perform }.to output(/myapp_vpc: invalid/).to_stdout
      end
    end

    context "missing parameters" do
      let(:template_file) { 'mystack-with-parameters.yaml' }

      context "--validate-template-parameters" do
        before { options.validate_template_parameters = true }

        it "informs the user of the problem" do
          expect { validator.perform }.to output(<<~OUTPUT).to_stdout
            myapp_vpc: invalid
            Empty/blank parameters detected. Please provide values for these parameters:
             - ParamOne
             - ParamTwo
            Parameters will be read from files matching the following globs:
             - parameters/myapp_vpc.y*ml
             - parameters/us-east-1/myapp_vpc.y*ml
          OUTPUT
        end
      end

      context "--no-validate-template-parameters" do
        before { options.validate_template_parameters = false }

        it "reports the stack as valid" do
          expect { validator.perform }.to output(/myapp_vpc: valid/).to_stdout
        end
      end
    end
  end

end
