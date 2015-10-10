module IntegrationDiffRails
  class Runner
    def self.instance
      @runner || = Runner.new(IntegrationDiffRails.base_uri,
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
      draft_run
      @images = []
    rescue StandardError => e
      Rails.logger.fatal e.message
      raise e
    end

    # TODO: Improve error handling here for network timeouts
    def wrap_run
      @images.each(&:upload_image)
      finalize_run
    rescue StandardError => e
      Rails.logger.fatal e.message
      raise e
    end

    def take_screenshot(identifier)
      page.save_screenshot(identifier, full: true)
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
      connection.post("/api/v1/runs/#{@run_id}/run_images", identifier: image,
                      image: image_io)
    end

    def finalize_run
      connection.put("/api/v1/runs/#{@run_id}/status", status: "finalized")
    end

    def connection
      @conn ||= Faraday.new(@base_uri) do |f|
        f.adapter :net_http
        f.request :multipart
        f.request :url_encoded
      end
    end
  end
end
