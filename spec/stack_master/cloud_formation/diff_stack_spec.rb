RSpec.describe StackMaster::CloudFormation::DiffStack do
  subject(:stack_master) { described_class.new(cf, stack_definition) }
  let(:cf) { Aws::CloudFormation::Client.new }
  let(:stack_definition) do
    StackMaster::Config::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures')
    )
  end
  let(:stack) { StackMaster::Stack.new(stack_name: 'myapp_vpc', region: 'us-east-1', stack_id: 123, cf: cf) }

  describe "#perform" do
    context "entirely new stack" do
      before do
        allow(StackMaster::Stack).to receive(:find).with('us-east-1', "myapp_vpc").and_return nil
        allow(stack_definition).to receive(:template_body).and_return("new stack body")
      end

      it "outputs the entire stack" do
        expect { stack_master.perform }.to output("Stack diff: \n\e[0;32;49m+new stack body\n\e[0m\\ No newline at end of file\nParameters diff: \n\e[0;32;49m+{\n\e[0m\e[0;32;49m+  \"param_1\": \"hello\"\n\e[0m\e[0;32;49m+}\n\e[0m\\ No newline at end of file\nNo stack found\n").to_stdout
      end
    end

    context "stack update" do
      before do
        allow(StackMaster::Stack).to receive(:find).with('us-east-1', "myapp_vpc").and_return stack
        allow(stack).to receive(:template_body).and_return "{}"
        allow(stack_definition).to receive(:parameters).and_return []
        allow(stack_definition).to receive(:template_body).and_return "{\"a\": 1}"
      end

      it "outputs the stack diff" do
        expect { stack_master.perform }.to output(/\+  \"a\"\: 1/).to_stdout
      end
    end
  end
end
