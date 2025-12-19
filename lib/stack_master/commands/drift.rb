require 'diffy'

module StackMaster
  module Commands
    class Drift
      include Command
      include Commander::UI

      DETECTION_COMPLETE_STATES = %w[
        DETECTION_COMPLETE
        DETECTION_FAILED
      ]

      def perform
        detect_stack_drift_result = cf.detect_stack_drift(stack_name: stack_name)
        drift_results = wait_for_drift_results(detect_stack_drift_result.stack_drift_detection_id)

        puts colorize("Drift Status: #{drift_results.stack_drift_status}",
                      stack_drift_status_color(drift_results.stack_drift_status))
        return if drift_results.stack_drift_status == 'IN_SYNC'

        failed

        resp = cf.describe_stack_resource_drifts(stack_name: stack_name)
        resp.stack_resource_drifts.each do |drift|
          display_drift(drift)
        end
      end

      private

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end

      def display_drift(drift)
        color = drift_color(drift)
        puts colorize([drift.stack_resource_drift_status,
                       drift.resource_type,
                       drift.logical_resource_id,
                       drift.physical_resource_id].join(' '), color)
        return unless drift.stack_resource_drift_status == 'MODIFIED'

        puts colorize('  Property differences:', color) unless drift.property_differences.empty?
        drift.property_differences.each do |property_difference|
          puts colorize("  - #{property_difference.difference_type} #{property_difference.property_path}", color)
        end
        puts colorize('  Resource diff:', color)
        display_resource_drift(drift)
      end

      def display_resource_drift(drift)
        diff = ::StackMaster::Diff.new(
          before: prettify_json(drift.expected_properties),
          after: prettify_json(drift.actual_properties)
        )
        diff.display_colorized_diff
      end

      def prettify_json(string)
        JSON.pretty_generate(JSON.parse(string)) + "\n"
      rescue StandardError => e
        puts "Failed to prettify drifted resource: #{e.message}"
        string
      end

      def stack_drift_status_color(stack_drift_status)
        case stack_drift_status
        when 'IN_SYNC'
          :green
        when 'DRIFTED'
          :yellow
        else
          :blue
        end
      end

      def drift_color(drift)
        case drift.stack_resource_drift_status
        when 'IN_SYNC'
          :green
        when 'MODIFIED'
          :yellow
        when 'DELETED'
          :red
        else
          :blue
        end
      end

      def wait_for_drift_results(detection_id)
        resp = nil
        start_time = Time.now
        loop do
          resp = cf.describe_stack_drift_detection_status(stack_drift_detection_id: detection_id)
          break if DETECTION_COMPLETE_STATES.include?(resp.detection_status)

          elapsed_time = Time.now - start_time
          raise "Timeout waiting for stack drift detection" if elapsed_time > @options.timeout

          sleep SLEEP_SECONDS
        end
        resp
      end

      def puts(string)
        StackMaster.stdout.puts(string)
      end

      extend Forwardable
      def_delegators :@stack_definition, :stack_name, :region
      def_delegators :StackMaster, :colorize

      SLEEP_SECONDS = 1
    end
  end
end
