module IntegrationDiff
  module Uploaders
    class Sequential
      DIR = 'tmp/idiff_images'.freeze

      def initialize(base_uri, run_id)
        @base_uri = base_uri
        @run_id = run_id
        @identifiers = []
      end

      def enqueue(identifier)
        @identifiers << identifier
      end

      def wrapup
        @identifiers.each do |identifier|
          upload_image(identifier)
        end
      end

      private

      def upload_image(identifier)
        IntegrationDiff.logger.fatal "uploading #{identifier}"
        image_io = Faraday::UploadIO.new(image_file(identifier), 'image/png')
        connection.post("/api/v1/runs/#{@run_id}/run_images",
                        identifier: identifier, image: image_io)
      end

      def image_file(identifier)
        "#{Dir.pwd}/#{DIR}/#{identifier}.png"
      end

      def connection
        @conn ||= Faraday.new(@base_uri, request: { timeout: 120, open_timeout: 120 }) do |f|
          f.request :basic_auth, IntegrationDiff.api_key, 'X'
          f.request :multipart
          f.request :url_encoded
          f.adapter :net_http
        end
      end
    end
  end
end
