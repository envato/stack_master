require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/max_length_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxLengthValidator do

  describe '#validate' do
    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string, max_length: 1}, parameter: 'a', valid: true},
        {definition: {type: :string, max_length: 1}, parameter: ['a'], valid: true},
        {definition: {type: :string, max_length: 1}, parameter: 'ab', valid: false, error: ['ab']},
        {definition: {type: :string, max_length: 1}, parameter: ['ab'], valid: false, error: ['ab']},

        {definition: {type: :string, max_length: 1, default: 'a'}, parameter: nil, valid: true},

        {definition: {type: :string, max_length: 1, multiple: true}, parameter: 'a,a', valid: true},
        {definition: {type: :string, max_length: 1, multiple: true}, parameter: 'a,,a', valid: true},
        {definition: {type: :string, max_length: 1, multiple: true}, parameter: 'a,, ab', valid: false, error: ['ab']},

        {definition: {type: :string, max_length: 1, multiple: true, default: 'a,a'}, parameter: nil, valid: true},

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

