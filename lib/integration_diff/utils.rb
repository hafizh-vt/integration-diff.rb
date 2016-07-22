module IntegrationDiff
  module Utils
    # http connection that will be used for uploading images
    def self.connection
      base_uri = IntegrationDiff.base_uri
      Faraday.new(base_uri, request: { timeout: 120, open_timeout: 120 }) do |f|
        f.request :basic_auth, IntegrationDiff.api_key, 'X'
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
      end
    end

    def self.images_dir
      'tmp/idiff_images'.freeze
    end

    def self.upload_image(run_id, identifier)
      IntegrationDiff.logger.fatal "uploading #{identifier}"
      image_io = Faraday::UploadIO.new(image_file(identifier), 'image/png')
      connection.post("/api/v1/runs/#{run_id}/run_images",
                      identifier: identifier, image: image_io)
    end

    def self.image_file(identifier)
      "#{Dir.pwd}/#{images_dir}/#{identifier}.png"
    end
  end
end
