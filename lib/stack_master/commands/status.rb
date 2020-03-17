require 'table_print'
require 'ruby-progressbar'

module StackMaster
  module Commands
    class Status
      include Command
      include StackMaster::Commands::TerminalHelper

      def initialize(config, options, show_progress = true)
        super(config, nil, options)
        @show_progress = show_progress
      end

      def perform
        progress if @show_progress
        status = @config.stacks.map do |stack_definition|
          stack_status = StackStatus.new(@config, stack_definition)
          allowed_accounts = stack_definition.allowed_accounts
          progress.increment if @show_progress
          {
            region: stack_definition.region,
            stack_name: stack_definition.stack_name,
            stack_status: running_in_allowed_account?(allowed_accounts) ? stack_status.status : "Disallowed account",
            different: running_in_allowed_account?(allowed_accounts) ? stack_status.changed_message : "N/A",
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

      def running_in_allowed_account?(allowed_accounts)
        StackMaster.skip_account_check? || identity.running_in_allowed_account?(allowed_accounts)
      end

      def identity
        @identity ||= StackMaster::Identity.new
      end
    end
  end
end
