require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/definition_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::DefinitionValidator do

  describe '#validate' do

    def validator(name, definition)
      described_class.new(name, definition).tap {|validator| validator.validate}
    end

    let(:key) {'key'}
    subject {validator(key, {type: type})}

    [:string, :number].each do |type|

      context "with :#{type} type definition" do

        let(:type) {type}

        it 'should be valid' do
          expect(subject.is_valid).to be_truthy
        end

        it 'should not have an error' do
          expect(subject.error).to be_nil
        end

      end

    end

    context 'with other type definition' do

      let(:type) {:other}

      it 'should not be valid' do
        expect(subject.is_valid).to be_falsey
      end

      it 'should have an error' do
        expect(subject.error).to eq "#{key}:#{type} valid types are #{[:string, :number]}"
      end

    end

  end

end