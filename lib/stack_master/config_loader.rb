module StackMaster
  class ConfigLoader
    def self.load!(config_file = 'stack_master.yml')
      new(config_file).load
    end

    def initialize(config_file)
      @config_file = config_file
    end

    def load
      config = YAML.load(File.read(@config_file))
      base_dir = File.dirname(File.expand_path(@config_file))
      stack_definitions = Config::StackDefinitions.new(base_dir)
      stack_definitions.load(config.fetch('stacks'))
      stack_definitions
    end
  end
end
