RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, definition) { "#{name}:#{error} is not in allowed_values:#{definition[:allowed_values]}" } }

    context 'string validation' do
      let(:definition) { {type: :string, allowed_values: ['a']} }
      include_examples 'validate valid parameter', 'a'
      include_examples 'validate valid parameter', ['a']
      include_examples 'validate invalid parameter', 'b', ['b']
      include_examples 'validate invalid parameter', ['b'], ['b']
    end

    context 'multiple string validation' do
      let(:definition) { {type: :string, allowed_values: ['a'], multiple: true} }
      include_examples 'validate valid parameter', 'a,a'
      include_examples 'validate invalid parameter', 'a,, a', ['']
      include_examples 'validate invalid parameter', 'a,,b', ['', 'b']
    end

    context 'validation with multiple default values' do
      let(:definition) { {type: :string, allowed_values: ['a'], multiple: true, default: 'a,a'} }
      include_examples 'validate valid parameter', nil
    end

    context 'numerical validation' do
      let(:definition) { {type: :number, allowed_values: [1]} }
      include_examples 'validate valid parameter', 1
      include_examples 'validate valid parameter', '1'
      include_examples 'validate valid parameter', [1]
      include_examples 'validate valid parameter', ['1']
      include_examples 'validate invalid parameter', 2, [2]
      include_examples 'validate invalid parameter', '2', ['2']
    end

    context 'validation wtih default value' do
      let(:definition) { {type: :number, allowed_values: [1], default: 1} }
      include_examples 'validate valid parameter', nil
    end
  end
end