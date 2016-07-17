require 'integration_diff/utils'

module IntegrationDiff
  module Uploaders
    class Concurrent
      DIR = 'tmp/idiff_images'.freeze
      MAX_NO_OF_THREADS = 20

      def initialize(run_id)
        @run_id = run_id
        @pool = ::Concurrent::FixedThreadPool.new(MAX_NO_OF_THREADS)
      end

      def enqueue(identifier)
        @pool.post do
          IntegrationDiff::Utils.upload_image(@run_id, identifier)
        end
      end

      def wrapup
        @pool.shutdown
      end
    end
  end
end
