RSpec.describe StackMaster::ParameterResolvers::ParameterStore do

  describe '#resolve' do

    let(:config) { double(base_dir: '/base') }
    let(:stack_definition) { double(stack_name: 'mystack', region: 'us-east-1') }
    subject(:resolver) { described_class.new(config, stack_definition) }
    let(:parameter_name) { 'TEST' }
    let(:parameter_value) { 'TEST' }
    let(:unknown_parameter_name) { 'NOTEST' }
    let(:unencryptable_parameter_name) { 'SECRETTEST' }


    context 'the parameter is defined' do
      before do
        Aws.config[:ssm] = {
          stub_responses: {
            get_parameter: {
              parameter: {
                name: parameter_name,
                value: parameter_value,
                type: "SecureString",
                version: 1
              }
            }
          }
        }
      end
  
      it 'should return the parameter value' do
        expect(resolver.resolve(parameter_name)).to eq parameter_value
      end
    end

    context 'the parameter is undefined' do
      before do
        Aws.config[:ssm] = {
          stub_responses: {
            get_parameter: 
              Aws::SSM::Errors::ParameterNotFound.new(unknown_parameter_name, "Parameter #{unknown_parameter_name} not found")
          }
        }
      end
      it 'should raise and error' do
        expect { resolver.resolve(unknown_parameter_name) }
            .to raise_error(Aws::SSM::Errors::ParameterNotFound, "Parameter #{unknown_parameter_name} not found")
      end
    end
  end
end
