require 'integration_diff/utils'

module IntegrationDiff
  module Uploaders
    class Sequential
      def initialize(run_id)
        @run_id = run_id
        @identifiers = []
      end

      def enqueue(identifier)
        @identifiers << identifier
      end

      def wrapup
        @identifiers.each do |identifier|
          IntegrationDiff::Utils.upload_image(@run_id, identifier)
        end
      end
    end
  end
end
