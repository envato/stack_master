require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/number_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::NumberValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, _definition) { "#{name}:#{error} are not Numbers" } }

    context 'string validation' do
      let(:definition) { {type: :string} }
      include_examples 'validate valid parameter', 'a'
    end

    context 'numerical validation with multiples and default' do
      let(:definition) { {type: :number, multiple: true, default: '1,2'} }
      include_examples 'validate valid parameter', nil
    end

    context 'numerical validation default' do
      let(:definition) { {type: :number, multiple: true, default: '1'} }
      include_examples 'validate valid parameter', nil
    end

    context 'numerical validation with multiples' do
      let(:definition) { {type: :number, multiple: true} }
      include_examples 'validate valid parameter', '1,2'
      include_examples 'validate valid parameter', [1, 2]
      include_examples 'validate invalid parameter', '1,1.', ['1.']
      include_examples 'validate invalid parameter', [{}], [{}]
    end

    context 'numerical validation' do
      let(:definition) { {type: :number} }
      include_examples 'validate valid parameter', 1
      include_examples 'validate valid parameter', ['1']
      include_examples 'validate invalid parameter', {}, [{}]
      include_examples 'validate invalid parameter', ['1.'], ['1.']
      include_examples 'validate invalid parameter', ['1.1.1'], ['1.1.1']
      include_examples 'validate invalid parameter', ['1a1'], ['1a1']
    end
  end
end
