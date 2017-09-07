require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/allowed_pattern_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedPatternValidator do

  describe '#validate' do

    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string, allowed_pattern: '^a'}, parameter: 'a', valid: true},
        {definition: {type: :string, allowed_pattern: '^a'}, parameter: ['a'], valid: true},
        {definition: {type: :string, allowed_pattern: '^a'}, parameter: 'b', valid: false, error: ['b']},
        {definition: {type: :string, allowed_pattern: '^a'}, parameter: ['b'], valid: false, error: ['b']},

        {definition: {type: :string, allowed_pattern: '^a', default: 'a'}, parameter: nil, valid: true},

        {definition: {type: :string, allowed_pattern: '^a', multiple: true}, parameter: 'a,ab', valid: true},
        {definition: {type: :string, allowed_pattern: '^a', multiple: true}, parameter: 'a,,ab', valid: false, error: ['']},
        {definition: {type: :string, allowed_pattern: '^a', multiple: true}, parameter: 'a,, b', valid: false, error: ['', 'b']},

        {definition: {type: :string, allowed_pattern: '^a', multiple: true, default: 'a,a'}, parameter: nil, valid: true},

        {definition: {type: :number, allowed_pattern: '^1'}, parameter: '1', valid: true},
        {definition: {type: :number, allowed_pattern: '^1'}, parameter: 1, valid: true},
        {definition: {type: :number, allowed_pattern: '^1'}, parameter: [1], valid: true},
        {definition: {type: :number, allowed_pattern: '^1'}, parameter: ['1'], valid: true},
        {definition: {type: :number, allowed_pattern: '^1'}, parameter: '2', valid: false, error: ['2']},
        {definition: {type: :number, allowed_pattern: '^1'}, parameter: 2, valid: false, error: [2]},

        {definition: {type: :number, allowed_pattern: '^1', default: '1'}, parameter: nil, valid: true},
    ]


    subject do
      validator = described_class.new(name, definition, parameter)
      validator.validate
      validator
    end

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
            expect(subject.error).to eql "name:#{error} does not match allowed_pattern:#{definition[:allowed_pattern]}"
          end

        end

      end

    end

  end

end