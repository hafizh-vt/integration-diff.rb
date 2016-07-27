require 'time'
require 'json'
require 'integration_diff/run_details'
require 'integration_diff/uploader'
require 'integration_diff/utils'

module IntegrationDiff
  class Runner
    include Capybara::DSL

    def self.instance
      @runner ||= Runner.new(IntegrationDiff.project_name,
                             IntegrationDiff.javascript_driver)
    end

    attr_accessor :browser, :device, :os
    attr_accessor :browser_version, :device_name, :os_version

    def initialize(project_name, javascript_driver)
      @project_name = project_name
      @javascript_driver = javascript_driver

      dir = IntegrationDiff::Utils.images_dir
      Dir.mkdir('tmp') unless Dir.exist?('tmp')
      Dir.mkdir(dir) unless Dir.exist?(dir)

      self.browser = 'firefox'
      self.device = 'desktop'
      self.os = 'linux'
    end

    # edited by @luthfiswees
    # TODO: Improve error handling here for network timeouts
    def start_run
      draft_run
      @uploader = IntegrationDiff::Uploader.build(@run_id)

    rescue StandardError => e
      IntegrationDiff.logger.fatal e.message
      raise e
    end

    # created by @luthfiswees
    # designed for running multiple runs
    def rerun(run_id)
      @run_id = run_id
      @uploader = IntegrationDiff::Uploader.build(@run_id)
    rescue StandardError => e
      IntegrationDiff.logger.fatal e.message
      raise e
    end

    # created by @luthfiswees
    # to upload images into the current run
    def upload_run 
      @uploader.wrapup

      # complete_run if @run_id
    rescue StandardError => e
      IntegrationDiff.logger.fatal e.message
      raise e
    end

    # TODO: Improve error handling here for network timeouts
    def wrap_run
      @uploader.wrapup

      complete_run if @run_id
    rescue StandardError => e
      IntegrationDiff.logger.fatal e.message
      raise e
    end

    def screenshot(identifier)
      identifier = identify identifier

      raise 'no browser information provided' if browser.nil?
      raise 'no device information provided' if device.nil?
      raise 'no os information provided' if os.nil?

      screenshot_name = IntegrationDiff::Utils.image_file(identifier)
      page.save_screenshot(screenshot_name, full: true)
      @uploader.enqueue(identifier, browser, device, os, browser_version,
                        device_name, os_version)
    end

    # to fetch run id from the current run
    def get_run_id 
      return @run_id
    end

    # to name a test into specific format
    def name_test(name)
      return "#{@project_name}-#{name}"
    end

    # to start multiple runs simultanously with different drivers
    def start_multiple_runs(array_of_drivers, path)
      start_run 
      array_of_drivers.each do |driver|
        `IDIFF_RUN_ID=#{IntegrationDiff.get_run_id} IDIFF_DRIVER=#{driver.to_s} rspec #{path} -fd`
      end
      wrap_run
    end

    private

    # function to give a tag to identifier
    def identify(identifier)
      name = "#{@project_name}-#{identifier}-#{ENV['IDIFF_DRIVER']}"

      return name 
    end

    def draft_run
      run_name = @project_name + "-" + Time.now.iso8601

      details = IntegrationDiff::RunDetails.new.details
      branch = details.branch
      author = details.author
      project = @project_name

      response = connection.post('/api/v1/runs',
                                 name: run_name, project: project, group: branch,
                                 author: author, js_driver: @javascript_driver)

      @run_id = JSON.parse(response.body)["id"]
    end

    def complete_run
      connection.put("/api/v1/runs/#{@run_id}/status", status: "completed")
    end

    def connection
      @connection ||= IntegrationDiff::Utils.connection
    end
  end
end
