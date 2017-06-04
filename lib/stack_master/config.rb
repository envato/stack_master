require 'deep_merge/rails_compat'
require 'active_support/core_ext/object/deep_dup'
require 'awesome_print'

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
                  :template_dir,
                  :stack_defaults,
                  :region_defaults,
                  :region_aliases,
                  :template_compilers,

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

      @template_dir = config.fetch('template_dir', nil)

      @region_defaults = Utils.underscore_keys_to_hyphen(config.fetch('region_defaults', {}))
      @stack_defaults = config.fetch('stack_defaults', {})
      @environment_defaults = config.fetch('environment_defaults', {})

      @stacks = []
      load_template_compilers(config)
      load_config
    end

    def filter(environment = nil, stack_name = nil)
      @stacks.select do |s|
        (environment.blank? || s.environment == environment || s.environment == environment.gsub('_', '-')) &&
          (stack_name.blank? || s.stack_name == stack_name || s.stack_name == stack_name.gsub('_', '-'))
      end
    end

    def find_stack(environment, stack_name)
      filter(environment, stack_name).first
    end

    private
    def load_template_compilers(config)
      @template_compilers = {}
      populate_template_compilers(config.fetch('template_compilers', {}))
      merge_defaults_to_user_defined_compilers
    end

    def merge_defaults_to_user_defined_compilers
      @template_compilers = default_template_compilers.merge(@template_compilers)
    end

    def populate_template_compilers user_defined_compilers
      user_defined_compilers.each do |key, val|
        @template_compilers[key.to_sym] = val.to_sym
      end
    end

    def default_template_compilers
      {
        rb: :sparkle_formation,
        json: :json,
        yml:  :yaml,
        yaml: :yaml,
      }
    end

    def load_config
      environments = @config.fetch('environments')

      environments.each do |name, attributes|
        environment_name = Utils.underscore_to_hyphen(name)
        environment_attributes = build_environment_defaults.deeper_merge!(attributes)

        region = environment_attributes['region']
        stacks = environment_attributes['stacks']

        load_stacks(stacks, environment_name, region)
      end
    end

    def build_environment_defaults
      @environment_defaults.deep_dup
    end

    def load_stacks(stacks, environment_name, region)
      region = Utils.underscore_to_hyphen(region)
      stacks.each do |stack_name, attributes|
        stack_name = Utils.underscore_to_hyphen(stack_name)
        stack_attributes = build_stack_defaults(region).deeper_merge!(attributes).merge(
            'environment' => environment_name,
            'region' => region,
            'stack_name' => stack_name,
            'base_dir' => @base_dir,
            'template_dir' => @template_dir,
          )
        @stacks << StackDefinition.new(stack_attributes)
      end
    end

    def build_stack_defaults(region)
      region_defaults = @region_defaults.fetch(region, {})
      @stack_defaults.deep_dup.deeper_merge!(region_defaults)
    end
  end
end
