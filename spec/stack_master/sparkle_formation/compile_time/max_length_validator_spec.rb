require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/max_length_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxLengthValidator do

  describe '#validate' do
    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string, max_length: 1}, parameter: 'a', valid: true},
        {definition: {type: :string, max_length: 1}, parameter: 'ab', valid: false, error: ['ab']},
        {definition: {type: :string, max_length: 1}, parameter: ['a', 'b'], valid: true},
        {definition: {type: :string, max_length: 1}, parameter: ['a', 'bc'], valid: false, error: ['bc']},
        {definition: {type: :string, max_length: 1}, parameter: ['ab', 'cd'], valid: false, error: ['ab', 'cd']},

        {definition: {type: :string, max_length: 1, default: 'a'}, parameter: nil, valid: true},
        {definition: {type: :string, max_length: 1, default: 'ab'}, parameter: nil, valid: false, error: ['ab']},
        {definition: {type: :string, max_length: 1, default: ['a', 'b']}, parameter: nil, valid: true},
        {definition: {type: :string, max_length: 1, default: ['a', 'bc']}, parameter: nil, valid: false, error: ['bc']},
        {definition: {type: :string, max_length: 1, default: ['ab', 'cd']}, parameter: nil, valid: false, error: ['ab', 'cd']},

        {definition: {type: :string, max_length: 1, multiple: true, default: 'a,b'}, parameter: nil, valid: true},
        {definition: {type: :string, max_length: 1, multiple: true, default: 'a,ab'}, parameter: nil, valid: false, error: ['ab']},
        {definition: {type: :string, max_length: 1, multiple: true, default: 'ab,bc'}, parameter: nil, valid: false, error: ['ab', 'bc']},
        # {definition: {type: :string, max_length: 1, multiple: true, default: 'ab,,cd'}, parameter: nil, valid: false, error: ['ab', nil, 'cd']},

        {definition: {type: :number, max_length: 1}, parameter: 'ab', valid: true}

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
            expect(subject.error).to eql "name:#{error} must not exceed max_length:#{definition[:max_length]} characters"
          end
        end
      end
    end
  end
end

