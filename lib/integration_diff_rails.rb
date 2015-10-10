require 'faraday'
require 'integration_diff_rails/runner'
require 'integration_diff_rails/rspec'

module IntegrationDiffRails
  # configure domain to which all images have to be uploaded.
  mattr_accessor :base_uri
  self.base_uri = "http://idf.dev"

  # configure project name to which images belong to.
  mattr_accessor :project_name
  self.project_name = "idf"

  # configure js driver which is used for taking screenshots.
  mattr_accessor :javascript_driver
  self.javascript_driver = "poltergeist"

  # helper to configure above variables.
  def self.configure
    yield(self)
  end

  # helps in setting up the run
  def self.start_run
    IntegrationDiffRails::Runner.instance.start_run
  end

  # helps in wrapping up run by uploading images
  def self.wrap_run
    IntegrationDiffRails::Runner.instance.wrap_run
  end
end
