RSpec.describe StackMaster::ParameterValidator do
  subject(:parameter_validator) { described_class.new(stack: stack, stack_definition: stack_definition) }

  let(:stack) { StackMaster::Stack.new(parameters: parameters, template_body: '{}', template_format: :json) }
  let(:parameter_files) { nil }
  let(:stack_definition) { StackMaster::StackDefinition.new(base_dir: '/base_dir', region: 'ap-southeast-2', stack_name: 'stack_name', parameter_files: parameter_files) }

  describe '#missing_parameters?' do
    subject { parameter_validator.missing_parameters? }

    context 'when a parameter has a nil value' do
      let(:parameters) { { 'my_param' => nil } }

      it { should eq true }
    end

    context 'when no parameers have a nil value' do
      let(:parameters) { { 'my_param' => '1' } }

      it { should eq false }
    end
  end

  describe '#error_message' do
    subject(:error_message) { parameter_validator.error_message }

    context 'when a parameter has a nil value' do
      let(:parameters) { { 'Param1' => true, 'Param2' => nil, 'Param3' => 'string', 'Param4' => nil } }

      it 'returns a descriptive message' do
        expect(error_message).to eq(<<~MESSAGE)
          Empty/blank parameters detected. Please provide values for these parameters:
           - Param2
           - Param4
          Parameters will be read from files matching the following globs:
           - parameters/stack_name.y*ml
           - parameters/ap-southeast-2/stack_name.y*ml
        MESSAGE
      end
    end

    context 'when the stack definition is using explicit parameter files' do
      let(:parameters) { { 'Param1' => true, 'Param2' => nil, 'Param3' => 'string', 'Param4' => nil } }
      let(:parameter_files) { ['params.yml'] }

      it 'returns a descriptive message' do
        expect(error_message).to eq(<<~MESSAGE)
          Empty/blank parameters detected. Please provide values for these parameters:
           - Param2
           - Param4
          Parameters are configured to be read from the following files:
           - /base_dir/parameters/params.yml
        MESSAGE
      end
    end

    context 'when no parameers have a nil value' do
      let(:parameters) { { 'Param' => '1' } }

      it { should eq nil }
    end
  end
end
