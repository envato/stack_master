RSpec.describe StackMaster::StackDefinition do
  subject(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: region,
      stack_name: stack_name,
      template: template,
      tags: tags,
      base_dir: base_dir,
      parameter_files: parameter_files
    )
  end

  let(:region) { 'us-east-1' }
  let(:stack_name) { 'stack_name' }
  let(:template) { 'template.json' }
  let(:tags) { { 'environment' => 'production' } }
  let(:base_dir) { '/base_dir' }
  let(:parameter_files) { nil }

  before do
    allow(Dir).to receive(:glob).with(
      File.join(base_dir, 'parameters', "#{stack_name}.y*ml")
    ).and_return(
      [
        "/base_dir/parameters/#{stack_name}.yaml",
        "/base_dir/parameters/#{stack_name}.yml",
      ]
    )

    allow(Dir).to receive(:glob).with(
      File.join(base_dir, 'parameters', "#{region}", "#{stack_name}.y*ml")
    ).and_return(
      [
        "/base_dir/parameters/#{region}/#{stack_name}.yaml",
        "/base_dir/parameters/#{region}/#{stack_name}.yml",
      ]
    )
  end

  it 'has default and region specific parameter file locations' do
    expect(stack_definition.all_parameter_files).to eq(
      [
        "/base_dir/parameters/#{stack_name}.yaml",
        "/base_dir/parameters/#{stack_name}.yml",
        "/base_dir/parameters/#{region}/#{stack_name}.yaml",
        "/base_dir/parameters/#{region}/#{stack_name}.yml",
      ]
    )
  end

  it 'returns all globs' do
    expect(stack_definition.parameter_file_globs).to eq(
      [
        "/base_dir/parameters/#{stack_name}.y*ml",
        "/base_dir/parameters/#{region}/#{stack_name}.y*ml",
      ]
    )
  end

  context 'given a stack_name with a dash' do
    let(:stack_name) { 'stack-name' }

    it 'returns globs supporting dashes and underscores in the parameter filenames' do
      expect(stack_definition.parameter_file_globs).to eq(
        [
          "/base_dir/parameters/stack[-_]name.y*ml",
          "/base_dir/parameters/#{region}/stack[-_]name.y*ml",
        ]
      )
    end
  end

  context 'with additional parameter lookup dirs' do
    before do
      stack_definition.additional_parameter_lookup_dirs = ['production']
      allow(Dir).to receive(:glob).with(
        File.join(base_dir, 'parameters', "production", "#{stack_name}.y*ml")
      ).and_return(
        [
          "/base_dir/parameters/production/#{stack_name}.yaml",
          "/base_dir/parameters/production/#{stack_name}.yml",
        ]
      )
    end

    it 'includes a parameter lookup dir for it' do
      expect(stack_definition.all_parameter_files).to eq(
        [
          "/base_dir/parameters/#{stack_name}.yaml",
          "/base_dir/parameters/#{stack_name}.yml",
          "/base_dir/parameters/#{region}/#{stack_name}.yaml",
          "/base_dir/parameters/#{region}/#{stack_name}.yml",
          "/base_dir/parameters/production/#{stack_name}.yaml",
          "/base_dir/parameters/production/#{stack_name}.yml",
        ]
      )
    end

    it 'returns all globs' do
      expect(stack_definition.parameter_file_globs).to eq(
        [
          "/base_dir/parameters/#{stack_name}.y*ml",
          "/base_dir/parameters/#{region}/#{stack_name}.y*ml",
          "/base_dir/parameters/production/#{stack_name}.y*ml",
        ]
      )
    end

    context 'given a stack_name with a dash' do
      let(:stack_name) { 'stack-name' }

      it 'returns globs supporting dashes and underscores in the parameter filenames' do
        expect(stack_definition.parameter_file_globs).to eq(
          [
            "/base_dir/parameters/stack[-_]name.y*ml",
            "/base_dir/parameters/#{region}/stack[-_]name.y*ml",
            "/base_dir/parameters/production/stack[-_]name.y*ml",
          ]
        )
      end
    end
  end

  it 'defaults ejson_file_kms to true' do
    expect(stack_definition.ejson_file_kms).to eq true
  end

  context "with explicit parameter_files" do
    let(:parameter_files) { ["my-stack.yml", "../my-stack.yml"] }

    it "ignores parameter globs and resolves them relative to parameters_dir" do
      expect(stack_definition.all_parameter_files).to eq ["/base_dir/parameters/my-stack.yml", "/base_dir/my-stack.yml"]
    end
  end
end
