RSpec.describe StackMaster::SparkleFormation::CompileTime::EmptyValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, _definition) { "#{name} cannot contain empty parameters:#{error.inspect}" } }

    context 'string validation' do
      let(:definition) { {type: :string} }
      include_examples 'validate valid parameter', described_class, 'a'
      include_examples 'validate valid parameter', described_class, ['a']
      include_examples 'validate invalid parameter', described_class, nil, nil
      include_examples 'validate invalid parameter', described_class, ['a', nil], ['a', nil]
    end

    context 'string validation with default' do
      let(:definition) { {type: :string, default: 'a'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'string validation with multiples' do
      let(:definition) { {type: :string, multiple: true} }
      include_examples 'validate valid parameter', described_class, 'a,b'
      include_examples 'validate invalid parameter', described_class, 'a,,b', 'a,,b'
    end

    context 'string validation with multiples and defaults' do
      let(:definition) { {type: :string, multiple: true, default: 'a,b'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation' do
      let(:definition) { {type: :number} }
      include_examples 'validate valid parameter', described_class, 1
      include_examples 'validate valid parameter', described_class, '1'
      include_examples 'validate valid parameter', described_class, [1]

      include_examples 'validate invalid parameter', described_class, nil, nil
      include_examples 'validate invalid parameter', described_class, [1, nil], [1, nil]
      include_examples 'validate invalid parameter', described_class, ['1', nil], ['1', nil]
    end

    context 'numerical validation with default' do
      let(:definition) { {type: :number, default: '1'} }
      include_examples 'validate valid parameter', described_class, nil
    end
  end
end
