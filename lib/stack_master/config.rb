module StackMaster
  class Config
    def self.load!(config_file = 'stack_master.yml')
      config = YAML.load(File.read(config_file))
      base_dir = File.dirname(File.expand_path(config_file))
      new(config, base_dir)
    end

    attr_accessor :stack_definitions,
                  :base_dir,
                  :stack_defaults,
                  :region_defaults

    def initialize(config, base_dir)
      @config = config
      @base_dir = base_dir
      @stack_defaults = underscore_keys_to_hyphen(config.fetch('stack_defaults', {}))
      @region_defaults = underscore_keys_to_hyphen(config.fetch('region_defaults', {}))
      load_config
    end

    extend Forwardable
    def_delegator :@stack_definitions, :find_stack, :find_stack

    private

    def load_config
      @stack_definitions = Config::StackDefinitions.new(@base_dir, @stack_defaults, @region_defaults)
      @stack_definitions.load(@config.fetch('stacks'))
    end

    def underscore_keys_to_hyphen(hash)
      hash.inject({}) do |hash, (key, value)|
        hash[key.gsub('_', '-')] = value
        hash
      end
    end
  end
end
