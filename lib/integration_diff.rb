require 'faraday'
require 'integration_diff/dummy_runner'
require 'integration_diff/runner'
require 'integration_diff/dsl'
require 'logger'

module IntegrationDiff
  # configure domain to which all images have to be uploaded.
  @@base_uri = "http://diff.codemancers.com"
  def self.base_uri=(uri)
    @@base_uri = uri
  end
  def self.base_uri
    @@base_uri
  end

  # configure project name to which images belong to.
  @@project_name = "idf"
  def self.project_name=(name)
    @@project_name = name
  end
  def self.project_name
    @@project_name
  end

  # configure api_key required to authorize api access
  @@api_key = ''
  def self.api_key=(key)
    @@api_key = key
  end
  def self.api_key
    @@api_key
  end

  # configure js driver which is used for taking screenshots.
  @@javascript_driver = "poltergeist"
  def self.javascript_driver=(driver)
    @@javascript_driver = driver
  end
  def self.javascript_driver
    @@javascript_driver
  end

  # configure service to be mocked so that no screenshots are
  # taken, and uploaded to service.
  @@enable_service = false
  def self.enable_service=(enable)
    @@enable_service = enable
  end
  def self.enable_service
    @@enable_service
  end

  # configure logger, which will be used to log issues if any
  @@logger = Logger.new(STDOUT)
  def self.logger=(new_logger)
    @@logger = new_logger
  end
  def self.logger
    @@logger
  end

  # helper to configure above variables.
  def self.configure
    yield(self)
  end

  # created by @luthfiswees
  # helps getting run id from existing runs
  def self.get_run_id 
    return IntegrationDiff::Dsl.idiff.get_run_id
  end

  # edited by @luthfiswees
  # helps in setting up the run
  def self.start_run
    IntegrationDiff::Dsl.idiff.start_run
  end

  # created by @luthfiswees
  # designed for reusing runs with same run id
  def self.rerun(run_id)
    IntegrationDiff::Dsl.idiff.rerun run_id
  end

  # created by @luthfiswees
  # helps uploading images to the current run avalaible
  def self.upload_run
    IntegrationDiff::Dsl.idiff.upload_run
  end

  # created by @luthfiswees
  # to name test with provided project name and driver
  def self.name_test(name)
    return IntegrationDiff::Dsl.idiff.name_test name
  end

  # helps in wrapping up run by uploading images
  def self.wrap_run
    IntegrationDiff::Dsl.idiff.wrap_run
  end
end
