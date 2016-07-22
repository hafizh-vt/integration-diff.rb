module IntegrationDiff
  class Uploader
    def self.build(run_id)
      if defined?(::Concurrent)
        require 'integration_diff/uploaders/concurrent'
        IntegrationDiff::Uploaders::Concurrent.new(run_id)
      else
        require 'integration_diff/uploaders/sequential'
        IntegrationDiff::Uploaders::Sequential.new(run_id)
      end
    end
  end
end
