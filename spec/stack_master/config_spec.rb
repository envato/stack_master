RSpec.describe StackMaster::Config do
  subject(:loaded_config) { StackMaster::Config.load!('spec/fixtures/stack_master.yml') }
  let(:base_dir) { File.expand_path('spec/fixtures') }
  let(:myapp_vpc_definition) do
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      region_alias: 'production',
      stack_name: 'myapp-vpc',
      template: 'myapp_vpc.json',
      allowed_accounts: ["555555555"],
      tags: { 'application' => 'my-awesome-blog', 'environment' => 'production' },
      s3: { 'bucket' => 'my-bucket', 'region' => 'us-east-1' },
      notification_arns: ['test_arn', 'test_arn_2'],
      role_arn: 'test_service_role_arn2',
      base_dir: base_dir,
      stack_policy_file: 'my_policy.json',
      additional_parameter_lookup_dirs: ['production']
    )
  end
  let(:bad_yaml) { "a: b\n- c" }

  describe ".load!" do
    it "fails to load the config if no stack_master.yml in parent directories" do
      expect { StackMaster::Config.load!('stack_master.yml') }.to raise_error Errno::ENOENT
    end

    it "raises exception on invalid yaml" do
      begin
        orig_dir = Dir.pwd
        Dir.chdir './spec/fixtures/'
        allow(File).to receive(:read).and_return(bad_yaml)
        expect { StackMaster::Config.load!('stack_master.yml') }.to raise_error StackMaster::Config::ConfigParseError
      ensure
        Dir.chdir orig_dir
      end
    end

    it "gives explicit error on badly indented entries" do
      Dir.chdir('./spec/fixtures/') do
        expect { StackMaster::Config.load!('stack_master_wrong_indent.yml') }
          .to raise_error StackMaster::Config::ConfigParseError
      end
    end

    it "gives explicit error on empty defaults" do
      Dir.chdir('./spec/fixtures/') do
        expect { StackMaster::Config.load!('stack_master_empty_default.yml') }
          .to raise_error StackMaster::Config::ConfigParseError
      end
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
      stack = loaded_config.find_stack('us-east-1', 'myapp-vpc')
      expect(stack).to eq(myapp_vpc_definition)
    end

    it 'can find things with underscores instead of hyphens' do
      stack = loaded_config.find_stack('us_east_1', 'myapp_vpc')
      expect(stack).to eq(myapp_vpc_definition)
    end
  end

  describe '#filter' do
    it 'returns a list of stack definitions' do
      stack = loaded_config.filter('us-east-1', 'myapp-vpc')
      expect(stack).to eq([myapp_vpc_definition])
    end

    it 'can filter by region only' do
      stacks = loaded_config.filter('us-east-1')
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
    expect(loaded_config.stack_defaults)
      .to eq(
        {
          'allowed_accounts' => ["555555555"],
          'tags' => { 'application' => 'my-awesome-blog' },
          's3' => { 'bucket' => 'my-bucket', 'region' => 'us-east-1' }
        }
      )
  end

  it 'loads template compiler mappings' do
    expect(loaded_config.template_compilers)
      .to eq(
        {
          rb: :ruby_dsl,
          json: :json,
          yml: :yaml,
          yaml: :yaml,
          erb: :yaml_erb,
        }
      )
  end

  it 'loads region defaults' do
    expect(loaded_config.region_defaults)
      .to eq(
        {
          'us-east-1' => {
            'tags' => { 'environment' => 'production' },
            'role_arn' => 'test_service_role_arn',
            'notification_arns' => ['test_arn'],
            'stack_policy_file' => 'my_policy.json'
          },
          'ap-southeast-2' => {
            'tags' => { 'environment' => 'staging', 'test_override' => 1 },
            'role_arn' => 'test_service_role_arn3',
            'notification_arns' => ['test_arn_3'],
          }
        }
      )
  end

  it 'loads region_aliases' do
    expect(loaded_config.region_aliases).to eq(
      'production' => 'us-east-1',
      'staging' => 'ap-southeast-2'
    )
  end

  it 'deep merges stack attributes' do
    expect(loaded_config.find_stack('ap-southeast-2', 'myapp-vpc'))
      .to eq(
        StackMaster::StackDefinition.new(
          stack_name: 'myapp-vpc',
          region: 'ap-southeast-2',
          region_alias: 'staging',
          allowed_accounts: ["555555555"],
          tags: { 'application' => 'my-awesome-blog', 'environment' => 'staging', 'test_override' => 1 },
          s3: { 'bucket' => 'my-bucket', 'region' => 'us-east-1' },
          role_arn: 'test_service_role_arn4',
          notification_arns: ['test_arn_3', 'test_arn_4'],
          template: 'myapp_vpc.rb',
          base_dir: base_dir,
          additional_parameter_lookup_dirs: ['staging']
        )
      )
    expect(loaded_config.find_stack('ap-southeast-2', 'myapp-web'))
      .to eq(
        StackMaster::StackDefinition.new(
          stack_name: 'myapp-web',
          region: 'ap-southeast-2',
          region_alias: 'staging',
          allowed_accounts: ["1234567890", "9876543210"],
          tags: { 'application' => 'my-awesome-blog', 'environment' => 'staging', 'test_override' => 2 },
          s3: { 'bucket' => 'my-bucket', 'region' => 'us-east-1' },
          role_arn: 'test_service_role_arn3',
          notification_arns: ['test_arn_3'],
          template: 'myapp_web',
          base_dir: base_dir,
          additional_parameter_lookup_dirs: ['staging']
        )
      )
  end

  it 'allows region aliases in region defaults' do
    config = StackMaster::Config.new(
      {
        'region_aliases' => { 'production' => 'us-east-1' },
        'region_defaults' => { 'production' => { 'secret_file' => 'production.yml.gpg' } },
        'stacks' => {}
      },
      '/base'
    )

    expect(config.region_defaults)
      .to eq('us-east-1' => { 'secret_file' => 'production.yml.gpg' })
  end
end
