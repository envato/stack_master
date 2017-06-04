require 'table_print'
require 'ruby-progressbar'

module StackMaster
  module Commands
    class Status
      include Command
      include StackMaster::Commands::TerminalHelper

      def initialize(config, show_progress = true)
        @config = config
        @show_progress = show_progress
      end

      def perform
        progress if @show_progress
        status = @config.stacks.map do |stack_definition|
          stack_status = StackStatus.new(@config, stack_definition)
          progress.increment if @show_progress
          {
            environment: stack_definition.environment,
            stack_name: stack_definition.stack_name,
            region: stack_definition.region,
            stack_status: stack_status.status,
            different: stack_status.changed_message,
          }
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
    end
  end
end
