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
    it 'outputs the message' do
      error_proc = proc {
        raise StackMaster::TemplateCompiler::TemplateCompilationFailed.new('the message')
      }
      expect { command_class.perform(error_proc) }.to output(/the message/).to_stderr
    end

    it 'outputs the exception\'s cause' do
      exception_with_cause = StackMaster::TemplateCompiler::TemplateCompilationFailed.new('the message')
      allow(exception_with_cause).to receive(:cause).and_return(RuntimeError.new('the cause message'))
      error_proc = proc {
        raise exception_with_cause
      }
      expect { command_class.perform(error_proc) }.to output(/Caused by: RuntimeError the cause message/).to_stderr
    end
  end
end
