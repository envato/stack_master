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
                  :region_defaults,
                  :region_aliases

    def initialize(config, base_dir)
      @config = config
      @base_dir = base_dir
      @stack_defaults = Utils.underscore_keys_to_hyphen(config.fetch('stack_defaults', {}))
      @region_defaults = Utils.underscore_keys_to_hyphen(config.fetch('region_defaults', {}))
      @region_aliases = Utils.underscore_keys_to_hyphen(config.fetch('region_aliases', {}))
      load_config
    end

    extend Forwardable
    def_delegator :@stack_definitions, :find_stack, :find_stack

    def unalias_region(region)
      @region_aliases.fetch(region) { region }
    end

    private

    def load_config
      @stack_definitions = Config::StackDefinitions.new(@base_dir, @stack_defaults, @region_defaults)
      unaliased_stacks = resolve_region_aliases(@config.fetch('stacks'))
      @stack_definitions.load(unaliased_stacks)
    end

    def resolve_region_aliases(stacks)
      stacks.inject({}) do |hash, (region, attributes)|
        hash[unalias_region(region)] = attributes
        hash
      end
    end
  end
end
