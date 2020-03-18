RSpec.describe StackMaster::Command do
  let(:command_class) {
    Class.new do
      include StackMaster::Command

      def initialize(callable = nil, halt = nil)
        @callable = callable
        @halt = halt
      end

      attr_reader :finished

      def perform
        instance_eval(&@callable) if @callable
        halt! if @halt
        @finished = true
        false
      end
    end
  }

  context 'when failed is not called' do
    it 'is successful' do
      expect(command_class.perform.success?).to eq true
    end
  end

  context 'when failed is called' do
    it 'is not successful' do
      expect(command_class.perform(proc { failed }).success?).to eq false
    end
  end

  describe '#halt!' do
    it 'exits the command' do
      expect(command_class.perform(nil, true).finished).to_not eq true
    end
  end

  context 'when a CF error occurs' do
    it 'outputs the message' do
      error_proc = proc {
        raise Aws::CloudFormation::Errors::ServiceError.new('a', 'the message')
      }
      expect { command_class.perform(error_proc) }.to output(/the message/).to_stderr
    end
  end

  context 'when a template compilation error occurs' do
    subject(:command) { command_class.new(error_proc) }

    let(:error_proc) do
      proc do
        raise StackMaster::TemplateCompiler::TemplateCompilationFailed, 'the message'
      end
    end

    it 'outputs the message' do
      expect { command.perform }.to output(/the message/).to_stderr
    end

    context 'when the error has a cause' do
      let(:error_proc) do
        proc do
          begin
            raise RuntimeError, 'the cause message'
          rescue
            raise StackMaster::TemplateCompiler::TemplateCompilationFailed, 'the message'
          end
        end
      end

      it 'outputs the cause message' do
        expect { command.perform }.to output(/Caused by: RuntimeError the cause message/).to_stderr
      end
    end

    context 'when --trace is set' do
      before { command.instance_variable_set(:@options, spy(trace: true)) }

      it 'outputs the backtrace' do
        expect { command.perform }.to output(%r{spec/stack_master/command_spec.rb:[\d]*:in }).to_stderr
      end
    end

    context 'when --trace is not set' do
      before { command.instance_variable_set(:@options, spy(trace: nil)) }

      it 'does not output the backtrace' do
        expect { command.perform }.not_to output(%r{spec/stack_master/command_spec.rb:[\d]*:in }).to_stderr
      end

      it 'informs to set --trace option to see the backtrace' do
        expect { command.perform }.to output(/Use --trace to view backtrace/).to_stderr
      end
    end
  end
end
