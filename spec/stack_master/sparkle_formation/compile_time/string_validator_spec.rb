require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/string_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::StringValidator do

  describe '#validate' do

    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string}, parameter: 'a', valid: true},
        {definition: {type: :string}, parameter: ['a'], valid: true},
        {definition: {type: :string}, parameter: {}, valid: false, error: [{}]},

        {definition: {type: :string, default: 'a'}, parameter: nil, valid: true},

        {definition: {type: :string, multiple: true}, parameter: 'a,b', valid: true},
        {definition: {type: :string, multiple: true}, parameter: [{}], valid: false, error: [{}]},

        {definition: {type: :string, multiple: true, default: 'a,a'}, parameter: nil, valid: true},

        {definition: {type: :number}, parameter: 1, valid: true},
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
            expect(subject.error).to eql "name:#{error} are not Strings"
          end

        end

      end

    end

  end

end