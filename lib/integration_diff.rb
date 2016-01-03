require 'faraday'
require 'integration_diff/dummy_runner'
require 'integration_diff/runner'
require 'integration_diff/dsl'

module IntegrationDiff
  # configure domain to which all images have to be uploaded.
  @@base_uri = "http://idf.dev"
  def self.base_uri=(uri)
    @@base_uri = uri
  end

  # configure project name to which images belong to.
  @@project_name = "idf"
  def self.project_name=(name)
    @@project_name = name
  end

  # configure api_key required to authorize api access
  @@api_key = ''
  def self.api_key=(key)
    @@api_key = key
  end

  # configure js driver which is used for taking screenshots.
  @@javascript_driver = "poltergeist"
  def self.javascript_driver=(driver)
    @@javascript_driver = driver
  end

  # configure service to be mocked so that no screenshots are
  # taken, and uploaded to service.
  @@enable_service = false
  def self.enable_service=(enable)
    @@enable_service = enable
  end

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
