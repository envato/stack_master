module StackMaster
  module Commands
    class Status
      include Command
      include StackMaster::Commands::Helper

      def initialize(config, show_progress = true)
        @config = config
        @show_progress = show_progress
      end

      def perform
        progress if @show_progress
        status = @config.stacks.map do |stack_definition|
          status = get_status(stack_definition)
          progress.increment if @show_progress
          status
        end
        tp.set :max_width, self.window_size
        tp.set :io, StackMaster.stdout
        tp status
        StackMaster.stdout.puts " * No echo parameters can't be diffed"
      end

      private

      def progress
        @progress ||= ProgressBar.create(title: "Fetching stack information",
                                         total: @config.stacks.size,
                                         output: StackMaster.stdout)
      end

      def sort_params(hash)
        hash.sort.to_h
      end

      def get_status(stack_definition)
        region = stack_definition.region
        stack_name = stack_definition.stack_name
        begin
          driver = StackMaster.cloud_formation_driver
          driver.set_region(region)
          stack = Stack.find(region, stack_name)
          if stack
            proposed_stack = Stack.generate(stack_definition, @config)
            differ = StackMaster::StackDiffer.new(proposed_stack, stack)
            different = differ.body_different? || differ.params_different?
            stack_status = stack.stack_status
            noecho = !differ.noecho_keys.empty?
          else
            different = true
            stack_status = nil
          end
        rescue Aws::CloudFormation::Errors::ValidationError
          stack_status = "missing"
          different = true
        end

        { region: region, stack_name: stack_name, stack_status: stack_status, different: different ? "Yes" : (noecho ? "No *" : "No") }
      end

    end
  end
end
