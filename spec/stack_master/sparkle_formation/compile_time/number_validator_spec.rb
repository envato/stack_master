require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/number_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::NumberValidator do
  describe '#validate' do
    let(:error_message) { -> (error, _) { "name:#{error} are not Numbers" } }
    let(:name) {'name'}

    context 'string validation' do
      let(:validator_definition) { {type: :string} }
      include_examples 'validate valid parameter', described_class, 'a'
    end

    context 'numerical validation with multiples and default' do
      let(:validator_definition) { {type: :number, multiple: true, default: '1,2'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation default' do
      let(:validator_definition) { {type: :number, multiple: true, default: '1'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation with multiples' do
      let(:validator_definition) { {type: :number, multiple: true} }
      include_examples 'validate valid parameter', described_class, '1,2'
      include_examples 'validate valid parameter', described_class, [1,2]
      include_examples 'validate invalid parameter', described_class, '1,1.', ['1.']
      include_examples 'validate invalid parameter', described_class, [{}], [{}]
    end

    context 'numerical validation' do
      let(:validator_definition) { {type: :number} }
      include_examples 'validate valid parameter', described_class, 1
      include_examples 'validate valid parameter', described_class, ['1']
      include_examples 'validate invalid parameter', described_class, {}, [{}]
      include_examples 'validate invalid parameter', described_class, ['1.'], ['1.']
      include_examples 'validate invalid parameter', described_class, ['1.1.1'], ['1.1.1']
      include_examples 'validate invalid parameter', described_class, ['1a1'], ['1a1']
    end
  end
end
