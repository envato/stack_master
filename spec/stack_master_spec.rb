RSpec.describe StackMaster do
  describe '.debug' do
    let(:message) { "Doing some stuff" }

    context 'when debugging' do
      before { allow(StackMaster).to receive(:debug?).and_return(true) }

      it 'outputs the message to STDERR' do
        expect { StackMaster.debug(message) }.to output(/\[DEBUG\] #{message}/).to_stderr
      end
    end

    context 'when not debugging' do
      before { allow(StackMaster).to receive(:debug?).and_return(false) }

      it "doesn't output the message to STDERR" do
        expect { StackMaster.debug(message) }.to output("").to_stderr
      end
    end
  end

  describe '.debug?' do
    subject { StackMaster.debug? }

    context "when debug! isn't called" do
      it { should eq false }
    end

    context 'when debug! is called' do
      before { StackMaster.debug! }

      it { should eq true }

      after { StackMaster.instance_variable_set('@debug', false) }
    end
  end

  describe '.interactive?' do
    subject { StackMaster.interactive? }

    context "when non_interactive! isn't called" do
      it { should eq true }
    end

    context 'when non_interactive! is called' do
      before { StackMaster.non_interactive! }

      it { should eq false }

      after { StackMaster.instance_variable_set('@non_interactive', false) }
    end
  end

  describe '.non_interactive?' do
    subject { StackMaster.non_interactive? }

    context "when non_interactive! isn't called" do
      it { should eq false }
    end

    context 'when non_interactive! is called' do
      before { StackMaster.non_interactive! }

      it { should eq true }

      after { StackMaster.instance_variable_set('@non_interactive', false) }
    end
  end
end
