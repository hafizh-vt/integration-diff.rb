require 'time'
require 'json'

module IntegrationDiff
  class Runner
    include Capybara::DSL

    DIR = 'tmp/idff_images'

    def self.instance
      @runner ||= Runner.new(IntegrationDiff.base_uri,
                             IntegrationDiff.project_name,
                             IntegrationDiff.javascript_driver)
    end

    def initialize(base_uri, project_name, javascript_driver)
      @base_uri = base_uri
      @project_name = project_name
      @javascript_driver = javascript_driver
      Dir.mkdir(DIR) unless Dir.exist?(DIR)
    end

    # TODO: Improve error handling here for network timeouts
    def start_run
      @identifiers = []
      draft_run
    rescue StandardError => e
      Rails.logger.fatal e.message
      raise e
    end

    # TODO: Improve error handling here for network timeouts
    def wrap_run
      @identifiers.each do |identifier|
        upload_image(identifier)
      end

      finalize_run if @run_id
    rescue StandardError => e
      Rails.logger.fatal e.message
      raise e
    end

    def screenshot(identifier)
      screenshot_name = image_file(identifier)
      page.save_screenshot(screenshot_name, full: true)
      @identifiers << identifier
    end

    private

    def draft_run
      run_name = @project_name + "-" + Time.now.iso8601

      # will have to make it configurable. ie, read from env.
      # https://github.com/code-mancers/integration-diff-rails/pull/4#discussion-diff-42290464
      branch = `git rev-parse --abbrev-ref HEAD`.strip
      author = `git config user.name`.strip
      project = IntegrationDiff.project_name

      response = connection.post('/api/v1/runs',
                                 name: run_name, project: project, group: branch,
                                 author: author, js_driver: @javascript_driver)

      @run_id = JSON.parse(response.body)["id"]
    end

    def upload_image(identifier)
      image_io = Faraday::UploadIO.new(image_file(identifier), 'image/png')
      connection.post("/api/v1/runs/#{@run_id}/run_images",
                      identifier: identifier, image: image_io)
    end

    def finalize_run
      connection.put("/api/v1/runs/#{@run_id}/status", status: "finalized")
    end

    def image_file(identifier)
      "#{DIR}/#{identifier}.png"
    end

    def connection
      @conn ||= Faraday.new(@base_uri) do |f|
        f.request :basic_auth, IntegrationDiff.api_key, 'X'
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
      end
    end
  end
end
