RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxLengthValidator do

  describe '#validate' do
    let(:error_message) { -> (error, definition) { "name:#{error} must not exceed max_length:#{definition[:max_length]} characters" } }    
    let(:name) {'name'}

    context 'string validation' do
      let(:definition) { {type: :string, max_length: 1} }
      include_examples 'validate valid parameter', described_class, 'a'
      include_examples 'validate valid parameter', described_class, ['a']
      include_examples 'validate invalid parameter', described_class, 'ab', ['ab']
      include_examples 'validate invalid parameter', described_class, ['ab'], ['ab']
    end

    context 'validation with default value' do
      let(:definition) { {type: :string, max_length: 1, default: 'a'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'string validation with multiples' do
      let(:definition) { {type: :string, max_length: 1, multiple: true} }

      include_examples 'validate valid parameter', described_class, 'a,a'
      include_examples 'validate valid parameter', described_class, 'a,,a'

      include_examples 'validate invalid parameter', described_class, 'a,, ab', ['ab']
    end

    context 'string validation wtih multiples and default' do
      let(:definition) { {type: :string, max_length: 1, multiple: true, default: 'a,a'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation' do
      let(:definition) { {type: :number, max_length: 1} }
      include_examples 'validate valid parameter', described_class, 'ab'
    end
  end
end
