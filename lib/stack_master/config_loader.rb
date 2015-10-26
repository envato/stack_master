module StackMaster
  class ConfigLoader
    def self.load!(config_file = 'stackmaster.yml')
      new(config_file).load
    end

    def initialize(config_file)
      @config_file = config_file
    end

    def load
      stack_definitions = Config::StackDefinitions.new
      config = YAML.load(File.read(@config_file))
      stack_definitions.load(config.fetch('stacks'))
      stack_definitions
    end
  end
end
