require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/number_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::NumberValidator do

  describe '#validate' do

    let(:name) {'name'}

    scenarios = [
        {definition: {type: :number}, parameter: 1, valid: true},
        {definition: {type: :number}, parameter: ['1'], valid: true},
        {definition: {type: :number}, parameter: ['1.'], valid: false, error: ['1.']},
        {definition: {type: :number}, parameter: ['.1'], valid: false, error: ['.1']},
        {definition: {type: :number}, parameter: ['1.1.1'], valid: false, error: ['1.1.1']},
        {definition: {type: :number}, parameter: ['1a1'], valid: false, error: ['1a1']},

        {definition: {type: :number}, parameter: {}, valid: false, error: [{}]},

        {definition: {type: :number, default: 1}, parameter: nil, valid: true},

        {definition: {type: :number, multiple: true}, parameter: '1,2', valid: true},
        {definition: {type: :number, multiple: true}, parameter: '1,1.', valid: false, error: ['1.']},
        {definition: {type: :number, multiple: true}, parameter: [1,2], valid: true},
        {definition: {type: :number, multiple: true}, parameter: [{}], valid: false, error: [{}]},

        {definition: {type: :number, multiple: true, default: '1,2'}, parameter: nil, valid: true},

        {definition: {type: :string}, parameter: 'a', valid: true}
    ]

    subject {described_class.new(name, definition, parameter).tap {|validator| validator.validate}}

    scenarios.each do |scenario|
      context_description = scenario.clone.tap {|clone| clone.delete(:valid); clone.delete(:error)}

      context "when #{context_description}" do
        let(:definition) {scenario[:definition]}
        let(:parameter) {scenario[:parameter]}
        let(:error) {scenario[:error]}

        if scenario[:valid]

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

        else

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should have an error' do
            expect(subject.error).to eql "name:#{error} are not Numbers"
          end

        end

      end

    end

  end

end