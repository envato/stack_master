RSpec.describe StackMaster::SparkleFormation::CompileTime::MinLengthValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, definition) { "#{name}:#{error} must be at least min_length:#{definition[:min_length]} characters" } }

    context 'string validation' do
      let(:definition) { {type: :string, min_length: 2} }
      include_examples 'validate valid parameter', 'ab'
      include_examples 'validate valid parameter', ['ab']
      include_examples 'validate invalid parameter', 'a', ['a']
      include_examples 'validate invalid parameter', ['a'], ['a']
    end

    context 'string validation with default value' do
      let(:definition) { {type: :string, min_length: 2, default: 'ab'} }
      include_examples 'validate valid parameter', nil
    end

    context 'string validation with multiples' do
      let(:definition) { {type: :string, min_length: 2, multiple: true} }
      include_examples 'validate valid parameter', 'ab,cd'
      include_examples 'validate invalid parameter', 'a,, cd', ['a', '']
    end

    context 'string validation wtih multiples and default' do
      let(:definition) { {type: :string, min_length: 2, multiple: true, default: 'ab,cd'} }
      include_examples 'validate valid parameter', nil
    end

    context 'numerical validation' do
      let(:definition) { {type: :number, min_length: 2} }
      include_examples 'validate valid parameter', 'a'
    end
  end
end
