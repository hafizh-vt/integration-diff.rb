require 'faraday'
require 'integration_diff/dummy_runner'
require 'integration_diff/runner'
require 'integration_diff/dsl'

module IntegrationDiff
  # configure domain to which all images have to be uploaded.
  mattr_accessor :base_uri
  self.base_uri = "http://idf.dev"

  # configure project name to which images belong to.
  mattr_accessor :project_name
  self.project_name = "idf"

  # configure api_key required to authorize api access
  mattr_accessor :api_key
  self.api_key = ''

  # configure js driver which is used for taking screenshots.
  mattr_accessor :javascript_driver
  self.javascript_driver = "poltergeist"

  # configure service to be mocked so that no screenshots are
  # taken, and uploaded to service.
  mattr_accessor :mock_service
  self.mock_service = true

  # helper to configure above variables.
  def self.configure
    yield(self)
  end

  # helps in setting up the run
  def self.start_run
    IntegrationDiff::Dsl.idiff.start_run
  end

  # helps in wrapping up run by uploading images
  def self.wrap_run
    IntegrationDiff::Dsl.idiff.wrap_run
  end
end
