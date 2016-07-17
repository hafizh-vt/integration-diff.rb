module IntegrationDiff
  class Uploader
    def self.build(base_uri, run_id)
      if defined?(::Concurrent)
        require 'integration_diff/uploaders/concurrent'
        IntegrationDiff::Uploaders::Concurrent.new(base_uri, run_id)
      else
        require 'integration_diff/uploaders/sequential'
        IntegrationDiff::Uploaders::Sequential.new(base_uri, run_id)
      end
    end
  end
end
