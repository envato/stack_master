RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxSizeValidator do

  describe '#validate' do
    let(:name) {'name'}
    let(:error_message) { -> (error, definition) { "name:#{error} must not be greater than max_size:#{definition[:max_size]}" } }        

    context 'numerical validation' do
      let(:validator_definition) { {type: :number, max_size: 1} }
      include_examples 'validate valid parameter', described_class, 1
      include_examples 'validate valid parameter', described_class, ['1']
      include_examples 'validate valid parameter', described_class, [1]
      include_examples 'validate valid parameter', described_class, ['1']
      include_examples 'validate invalid parameter', described_class, 2, [2]
      include_examples 'validate invalid parameter', described_class, '2', ['2']
    end

    context 'numerical validation with default' do
      let(:validator_definition) { {type: :number, max_size: 1, default: 1} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'string validation' do
      let(:validator_definition) { {type: :string, max_size: 1} }
      include_examples 'validate valid parameter', described_class, 2
    end
  end
end