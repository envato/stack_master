RSpec.describe StackMaster::Config do
  subject(:loaded_config) { StackMaster::Config.load!('spec/fixtures/stack_master.yml') }
  let(:base_dir) { File.expand_path('spec/fixtures') }
  let(:myapp_vpc_definition) {
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      environment: 'production',
      stack_name: 'myapp-vpc',
      template: 'myapp_vpc.json',
      tags: { 'application' => 'my-awesome-blog', 'environment' => 'production' },
      s3: { 'bucket' => 'my-bucket', 'region' => 'us-east-1' },
      notification_arns: ['test_arn', 'test_arn_2'],
      role_arn: 'test_service_role_arn2',
      base_dir: base_dir,
      secret_file: 'production.yml.gpg',
      stack_policy_file: 'my_policy.json',
    )
  }

  describe ".load!" do
    it "fails to load the config if no stack_master.yml in parent directories" do
      expect { StackMaster::Config.load!('stack_master.yml') }.to raise_error Errno::ENOENT
    end

    it "searches up the tree for stack master yaml" do
      begin
        orig_dir = Dir.pwd
        Dir.chdir './spec/fixtures/templates'
        expect(StackMaster::Config.load!('stack_master.yml')).to_not be_nil
      ensure
        Dir.chdir orig_dir
      end
    end
  end

  describe '#find_stack' do
    it 'returns an object that can find stack definitions' do
      stack = loaded_config.find_stack('production', 'myapp-vpc')
      expect(stack).to eq(myapp_vpc_definition)
    end

    it 'can find things with underscores instead of hyphens' do
      stack = loaded_config.find_stack('production', 'myapp_vpc')
      expect(stack).to eq(myapp_vpc_definition)
    end
  end

  describe '#filter' do
    it 'returns a list of stack definitions' do
      stack = loaded_config.filter('production', 'myapp-vpc')
      expect(stack).to eq([myapp_vpc_definition])
    end

    it 'can filter by region only' do
      stacks = loaded_config.filter('production')
      expect(stacks.size).to eq 3
    end

    it 'can return all stack definitions with no filters' do
      stacks = loaded_config.filter
      expect(stacks.size).to eq 5
    end
  end

  it 'exposes the base_dir' do
    expect(loaded_config.base_dir).to eq base_dir
  end

  it 'loads stack defaults' do
    expect(loaded_config.stack_defaults).to eq({
      'tags' => { 'application' => 'my-awesome-blog' },
      's3' => { 'bucket' => 'my-bucket', 'region' => 'us-east-1' }
    })
  end

  it 'loads template compiler mappings' do
    expect(loaded_config.template_compilers).to eq({
                                                     rb: :ruby_dsl,
                                                     json: :json,
                                                     yml: :yaml,
                                                     yaml: :yaml,

                                                   })
  end

  it 'loads region defaults' do
    expect(loaded_config.region_defaults).to eq({
      'us-east-1' => {
        'tags' => { 'environment' => 'production' },
        'role_arn' => 'test_service_role_arn',
        'notification_arns' => ['test_arn'],
        'secret_file' => 'production.yml.gpg',
        'stack_policy_file' => 'my_policy.json'
      },
      'ap-southeast-2' => {
        'tags' => {'environment' => 'staging', 'test_override' => 1 },
        'role_arn' => 'test_service_role_arn3',
        'notification_arns' => ['test_arn_3'],
        'secret_file' => 'staging.yml.gpg'
      }
    })
  end

  it 'deep merges stack attributes' do
    expect(loaded_config.find_stack('staging', 'myapp-vpc')).to eq(StackMaster::StackDefinition.new(
      stack_name: 'myapp-vpc',
      region: 'ap-southeast-2',
      environment: 'staging',
      tags: {
        'application' => 'my-awesome-blog',
        'environment' => 'staging',
        'test_override' => 1
      },
      s3: { 'bucket' => 'my-bucket', 'region' => 'us-east-1' },
      role_arn: 'test_service_role_arn4',
      notification_arns: ['test_arn_3', 'test_arn_4'],
      template: 'myapp_vpc.rb',
      base_dir: base_dir,
      secret_file: 'staging.yml.gpg',
    ))
    expect(loaded_config.find_stack('staging', 'myapp-web')).to eq(StackMaster::StackDefinition.new(
      stack_name: 'myapp-web',
      region: 'ap-southeast-2',
      environment: 'staging',
      tags: {
        'application' => 'my-awesome-blog',
        'environment' => 'staging',
        'test_override' => 2
      },
      s3: { 'bucket' => 'my-bucket', 'region' => 'us-east-1' },
      role_arn: 'test_service_role_arn3',
      notification_arns: ['test_arn_3'],
      template: 'myapp_web',
      base_dir: base_dir,
      secret_file: 'staging.yml.gpg',
    ))
  end
end
