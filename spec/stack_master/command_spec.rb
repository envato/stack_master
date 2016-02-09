RSpec.describe StackMaster::Command do
  let(:command_class) {
    Class.new do
      include StackMaster::Command

      def initialize(callable = nil)
        @callable = callable
      end

      def perform
        instance_eval(&@callable) if @callable
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
end
