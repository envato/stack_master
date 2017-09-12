RSpec.describe StackMaster::SparkleFormation::CompileTime::MinSizeValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, definition) { "#{name}:#{error} must not be lesser than min_size:#{definition[:min_size]}" } }

    context 'string validation' do
      let(:definition) { {type: :string, min_size: 1} }
      include_examples 'validate valid parameter', 0
    end

    context 'numerical validation with default value' do
      let(:definition) { {type: :number, min_size: 1, default: 1} }
      include_examples 'validate valid parameter', nil
    end

    context 'numerical validation' do
      let(:definition) { {type: :number, min_size: 1} }
      include_examples 'validate valid parameter', 1
      include_examples 'validate valid parameter', '1'
      include_examples 'validate valid parameter', [1]
      include_examples 'validate valid parameter', ['1']
      include_examples 'validate invalid parameter', 0, [0]
      include_examples 'validate invalid parameter', '0', ['0']
    end
  end
end
