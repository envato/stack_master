require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/definitions_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::DefinitionsValidator do

  describe '#validate' do

    let(:key) {'key'}
    subject {described_class.new({"#{key}": {type: type}}).tap {|validator| validator.validate}}

    [:string, :number].each do |type|

      context "with :#{type} type definition" do

        let(:type) {type}

        it 'should not raise an exception' do
          expect {subject}.to_not raise_error
        end

      end

    end

    context 'with other type definition' do

      let(:type) {:other}

      it 'should not raise an exception' do
        expect {subject}.to raise_error(ArgumentError, "Unknown compile time parameter type: #{key}:#{type} valid types are #{[:string, :number]}")
      end

    end

  end

end