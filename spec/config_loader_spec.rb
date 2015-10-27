RSpec.describe StackMaster::ConfigLoader do
  subject(:loaded_config) { StackMaster::ConfigLoader.load!('spec/fixtures/stack_master.yml') }

  it 'returns an object that can find stack definitions' do
    myapp_vpc_definition = StackMaster::Config::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures')
    )
    stack = loaded_config.find_stack('us-east-1', 'myapp_vpc')
    expect(stack).to eq(myapp_vpc_definition)
  end
end
