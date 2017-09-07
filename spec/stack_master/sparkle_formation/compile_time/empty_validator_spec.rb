require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/empty_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::EmptyValidator do

  describe '#validate' do

    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string}, parameter: 'a', valid: true},
        {definition: {type: :string}, parameter: ['a'], valid: true},
        {definition: {type: :string}, parameter: nil, valid: false},
        {definition: {type: :string}, parameter: ['a', nil], valid: false},

        {definition: {type: :string, default: 'a'}, parameter: nil, valid: true},

        {definition: {type: :string, multiple: true}, parameter: 'a,b', valid: true},
        {definition: {type: :string, multiple: true}, parameter: 'a,,b', valid: false},

        {definition: {type: :string, multiple: true, default: 'a,b'}, parameter: nil, valid: true},

        {definition: {type: :number}, parameter: 1, valid: true},
        {definition: {type: :number}, parameter: '1', valid: true},
        {definition: {type: :number}, parameter: [1], valid: true},
        {definition: {type: :number}, parameter: ['1'], valid: true},
        {definition: {type: :number}, parameter: nil, valid: false},
        {definition: {type: :number}, parameter: [1, nil], valid: false},
        {definition: {type: :number}, parameter: ['1', nil], valid: false},

        {definition: {type: :number, default: '1'}, parameter: nil, valid: true},
    ]

    subject {described_class.new(name, definition, parameter).tap {|validator| validator.validate}}

    scenarios.each do |scenario|
      context_description = scenario.clone.tap {|clone| clone.delete(:valid)}

      context "when #{context_description}" do
        let(:definition) {scenario[:definition]}
        let(:parameter) {scenario[:parameter]}

        if scenario[:valid]

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

        else

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should have an error' do
            expect(subject.error).to eql "#{name} cannot contain empty parameters:#{parameter.inspect}"
          end

        end

      end

    end

  end

end