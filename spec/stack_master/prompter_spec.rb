RSpec.describe StackMaster::Prompter do
  include StackMaster::Prompter

  context 'when STDIN is not a TTY' do
    before do
      allow(StackMaster.stdin).to receive(:tty?).and_return(false)
    end

    it 'defaults to no and outputs info about -y' do
      expect { ask?('blah') }.to output(/To force yes use -y/).to_stdout
    end
  end

  context 'when STDOUT is not a TTY' do
    before do
      allow(StackMaster.stdout).to receive(:tty?).and_return(false)
    end

    it 'defaults to no and outputs info about -y' do
      expect { ask?('blah') }.to output(/To force yes use -y/).to_stdout
    end
  end
end
