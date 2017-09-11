RSpec.describe StackMaster::SparkleFormation::CompileTime::ValueBuilder do

  scenarios= [
      {definition: {type: :string}, parameter: nil, expected: nil},
      {definition: {type: :string}, parameter: 'a', expected: 'a'},
      {definition: {type: :string}, parameter: ['a'], expected: ['a']},

      {definition: {type: :string, default: 'a'}, parameter: nil, expected: 'a'},

      {definition: {type: :string, multiple: true}, parameter: 'a', expected: ['a']},
      {definition: {type: :string, multiple: true}, parameter: 'a,b', expected: ['a', 'b']},
      {definition: {type: :string, multiple: true}, parameter: 'a, b', expected: ['a', 'b']},

      {definition: {type: :string, multiple: true, default: 'a'}, parameter: nil, expected: ['a']},

      {definition: {type: :number}, parameter: nil, expected: nil},
      {definition: {type: :number}, parameter: 1, expected: 1},
      {definition: {type: :number}, parameter: '1', expected: 1},
      {definition: {type: :number}, parameter: [1], expected: [1]},
      {definition: {type: :number}, parameter: ['1'], expected: [1]},

      {definition: {type: :number, default: '1'}, parameter: nil, expected: 1},

      {definition: {type: :number, multiple: true}, parameter: 1, expected: 1},
      {definition: {type: :number, multiple: true}, parameter: '1', expected: [1]},
      {definition: {type: :number, multiple: true}, parameter: '1,2', expected: [1,2]},
      {definition: {type: :number, multiple: true}, parameter: '1, 2', expected: [1,2]},

      {definition: {type: :number, multiple: true, default: '1'}, parameter: nil, expected: [1]}
  ]

  describe '#build' do

    scenarios.each do |scenario|

      description = scenario.clone.tap {|clone| clone.delete(:expected)}
      context "when #{description}" do

        definition = scenario[:definition]
        parameter = scenario[:parameter]
        expected = scenario[:expected]

        it("should have a value of #{expected}") do
          expect(described_class.new(definition, parameter).build).to eq expected
        end

      end

    end

  end

end