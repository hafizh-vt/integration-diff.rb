module IntegrationDiffRails
  class Runner
    def self.instance
      @runner ||= Runner.new(IntegrationDiffRails.base_uri,
                             IntegrationDiffRails.project_name,
                             IntegrationDiffRails.javascript_driver)
    end

    def initialize(base_uri, project_name, javscript_driver)
      @base_uri = base_uri
      @project_name = project_name
      @javscript_driver = javscript_driver
    end

    # TODO: Improve error handling here for network timeouts
    def start_run
      @images = []
      draft_run
    rescue StandardError => e
      Rails.logger.fatal e.message
      raise e
    end

    # TODO: Improve error handling here for network timeouts
    def wrap_run
      @images.each do |image|
        upload_image(image)
      end

      finalize_run if @run_id
    rescue StandardError => e
      Rails.logger.fatal e.message
      raise e
    end

    def take_screenshot(page, identifier)
      screenshot_name = #{identifier}.png"
      page.save_screenshot(screenshot_name, full: true)
      @images << screenshot_name
    end

    private

    def draft_run
      run_name = @project_name + "-" + Time.current.iso8601
      response = connection.post("/api/v1/runs", name: run_name)
      @run_id = JSON.parse(response.body)["id"]
    end

    def upload_image(image)
      image_file = File.new(image)
      image_io = Faraday::UploadIO.new(image_file, 'image/png')
      connection.post("/api/v1/runs/#{@run_id}/run_images",
                      identifier: image, image: image_io)
    end

    def finalize_run
      connection.put("/api/v1/runs/#{@run_id}/status", status: "finalized")
    end

    def connection
      @conn ||= Faraday.new(@base_uri) do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
      end
    end
  end
end
