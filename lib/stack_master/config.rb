require 'deep_merge/rails_compat'
require 'active_support/core_ext/object/deep_dup'

module StackMaster
  class Config
    def self.load!(config_file = 'stack_master.yml')
      resolved_config_file = search_up_and_chdir(config_file)
      config = YAML.load(File.read(resolved_config_file))
      base_dir = File.dirname(File.expand_path(resolved_config_file))
      new(config, base_dir)
    end

    attr_accessor :stacks,
                  :base_dir,
                  :stack_defaults,
                  :region_defaults,
                  :region_aliases

    def self.search_up_and_chdir(config_file)
      return config_file unless File.dirname(config_file) == "."

      dir = Dir.pwd
      parent_dir = File.expand_path("..", Dir.pwd)
      while parent_dir != dir && !File.exists?(File.join(dir, config_file))
        dir = parent_dir
        parent_dir = File.expand_path("..", dir)
      end

      File.join(dir, config_file)
    end

    def initialize(config, base_dir)
      @config = config
      @base_dir = base_dir
      @stack_defaults = config.fetch('stack_defaults', {})
      @region_aliases = Utils.underscore_keys_to_hyphen(config.fetch('region_aliases', {}))
      @region_to_aliases = @region_aliases.inject({}) do |hash, (key, value)|
        hash[value] ||= []
        hash[value] << key
        hash
      end
      @region_defaults = normalise_region_defaults(config.fetch('region_defaults', {}))
      @stacks = []
      load_config
    end

    def find_stack(region, stack_name)
      @stacks.find do |s|
        (s.region == region || s.region == region.gsub('_', '-')) &&
          (s.stack_name == stack_name || s.stack_name == stack_name.gsub('_', '-'))
      end
    end

    def unalias_region(region)
      @region_aliases.fetch(region) { region }
    end

    private

    def load_config
      unaliased_stacks = resolve_region_aliases(@config.fetch('stacks'))
      load_stacks(unaliased_stacks)
    end

    def resolve_region_aliases(stacks)
      stacks.inject({}) do |hash, (region, attributes)|
        hash[unalias_region(region)] = attributes
        hash
      end
    end

    def load_stacks(stacks)
      stacks.each do |region, stacks_for_region|
        region = Utils.underscore_to_hyphen(region)
        stacks_for_region.each do |stack_name, attributes|
          stack_name = Utils.underscore_to_hyphen(stack_name)
          stack_attributes = build_stack_defaults(region).deeper_merge!(attributes).merge(
            'region' => region,
            'stack_name' => stack_name,
            'base_dir' => @base_dir,
            'additional_parameter_lookup_dirs' => @region_to_aliases[region])
          @stacks << StackDefinition.new(stack_attributes)
        end
      end
    end

    def build_stack_defaults(region)
      region_defaults = @region_defaults.fetch(region, {}).deep_dup
      @stack_defaults.deep_dup.deeper_merge(region_defaults)
    end

    def normalise_region_defaults(region_defaults)
      region_defaults.inject({}) do |normalised_aliases, (region_or_alias, value)|
        region = unalias_region(region_or_alias)
        normalised_aliases[Utils.underscore_to_hyphen(region)] = value
        normalised_aliases
      end
    end
  end
end
