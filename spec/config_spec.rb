RSpec.describe StackMaster::Config do
  subject(:loaded_config) { StackMaster::Config.load!('spec/fixtures/stack_master.yml') }
  let(:base_dir) { File.expand_path('spec/fixtures') }
  let(:myapp_vpc_definition) {
    StackMaster::Config::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp-vpc',
      template: 'myapp_vpc.json',
      tags: { 'application' => 'my-awesome-blog', 'environment' => 'production' },
      notification_arns: ['test_arn', 'test_arn_2'],
      base_dir: base_dir,
      secret_file: 'production.yml.gpg',
      stack_policy_file: 'my_policy.json'
    )
  }

  it 'returns an object that can find stack definitions' do
    stack = loaded_config.find_stack('us-east-1', 'myapp-vpc')
    expect(stack).to eq(myapp_vpc_definition)
  end

  it 'can find things with underscores instead of hyphens' do
    stack = loaded_config.find_stack('us_east_1', 'myapp_vpc')
    expect(stack).to eq(myapp_vpc_definition)
  end

  it 'exposes the base_dir' do
    expect(loaded_config.base_dir).to eq base_dir
  end

  it 'loads stack defaults' do
    expect(loaded_config.stack_defaults).to eq({
      'tags' => { 'application' => 'my-awesome-blog' }
    })
  end

  it 'loads region defaults' do
    expect(loaded_config.region_defaults).to eq({
      'us-east-1' => {
        'tags' => { 'environment' => 'production' },
        'notification_arns' => ['test_arn'],
        'secret_file' => 'production.yml.gpg',
        'stack_policy_file' => 'my_policy.json'
      },
      'ap-southeast-2' => {
        'tags' => {'environment' => 'staging'},
        'notification_arns' => ['test_arn_3'],
        'secret_file' => 'staging.yml.gpg'
      }
    })
  end

  it 'loads region_aliases' do
    expect(loaded_config.region_aliases).to eq(
      'production' => 'us-east-1',
      'staging' => 'ap-southeast-2'
    )
  end

  it 'deep merges stack attributes' do
    expect(loaded_config.find_stack('ap-southeast-2', 'myapp-vpc')).to eq(StackMaster::Config::StackDefinition.new(
      stack_name: 'myapp-vpc',
      region: 'ap-southeast-2',
      tags: {
        'application' => 'my-awesome-blog',
        'environment' => 'staging'
      },
      notification_arns: ['test_arn_3', 'test_arn_4'],
      template: 'myapp_vpc.rb',
      base_dir: base_dir,
      secret_file: 'staging.yml.gpg'
    ))
  end
end
