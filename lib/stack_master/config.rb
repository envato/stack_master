module StackMaster
  class Config
    def self.load!(config_file = 'stack_master.yml')
      config = YAML.load(File.read(config_file))
      base_dir = File.dirname(File.expand_path(config_file))
      new(config, base_dir)
    end

    attr_accessor :stack_definitions, :base_dir

    def initialize(config, base_dir)
      @config = config
      @base_dir = base_dir
      load_config
    end

    extend Forwardable
    def_delegator :@stack_definitions, :find_stack, :find_stack

    private

    def load_config
      @stack_definitions = Config::StackDefinitions.new(@base_dir)
      @stack_definitions.load(@config.fetch('stacks'))
    end
  end
end
