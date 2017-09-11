require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/string_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::StringValidator do
  describe '#validate' do
    let(:error_message) { -> (error, _) { "name:#{error} are not Strings" } }
    let(:name) {'name'}

    context 'string validation' do
      let(:validator_definition) { {type: :string} }
      include_examples 'validate valid parameter', described_class, 'a'
      include_examples 'validate valid parameter', described_class, ['a']
      include_examples 'validate invalid parameter', described_class, {}, [{}]
    end

    context 'string validation default' do
      let(:validator_definition) { {type: :string, default: 'a'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'string validation with multiples' do
      let(:validator_definition) { {type: :string, multiple: true} }
      include_examples 'validate valid parameter', described_class, 'a,b'
      include_examples 'validate invalid parameter', described_class, [{}], [{}]
    end

    context 'string validation with multiples and default' do
      let(:validator_definition) { {type: :string, multiple: true, default: 'a,a'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation' do
      let(:validator_definition) { {type: :number} }
      include_examples 'validate valid parameter', described_class, 1
    end
  end
end
