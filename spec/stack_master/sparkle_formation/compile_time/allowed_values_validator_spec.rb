RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, validator_definition) { "name:#{error} is not in allowed_values:#{validator_definition[:allowed_values]}" } }

    context 'string validation' do
      let(:validator_definition) { {type: :string, allowed_values: ['a']} }
      include_examples 'validate valid parameter', described_class, 'a'
      include_examples 'validate valid parameter', described_class, ['a']
      include_examples 'validate invalid parameter', described_class, 'b', ['b']
      include_examples 'validate invalid parameter', described_class, ['b'], ['b']
    end

    context 'multiple string validation' do
      let(:validator_definition) { {type: :string, allowed_values: ['a'], multiple: true} }
      include_examples 'validate valid parameter', described_class, 'a,a'
      include_examples 'validate invalid parameter', described_class, 'a,, a', ['']
      include_examples 'validate invalid parameter', described_class, 'a,,b', ['', 'b']
    end

    context 'validation with multiple default values' do
      let(:validator_definition) { {type: :string, allowed_values: ['a'], multiple: true, default: 'a,a'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation' do
      let(:validator_definition) { {type: :number, allowed_values: [1]} }
      include_examples 'validate valid parameter', described_class, 1
      include_examples 'validate valid parameter', described_class, '1'
      include_examples 'validate valid parameter', described_class, [1]
      include_examples 'validate valid parameter', described_class, ['1']
      include_examples 'validate invalid parameter', described_class, 2, [2]
      include_examples 'validate invalid parameter', described_class, '2', ['2']
    end

    context 'validation wtih default value' do
      let(:validator_definition) { {type: :number, allowed_values: [1], default: 1} }
      include_examples 'validate valid parameter', described_class, nil
    end
  end
end