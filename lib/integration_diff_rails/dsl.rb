module IntegrationDiffRails
  module Dsl
    def self.idiff
      @idiff ||=
        begin
          klass =
            if IntegrationDiffRails.mock_service
              IntegrationDiffRails::DummyRunner
            else
              IntegrationDiffRails::Runner
            end

          Rails.logger.info "Using runner #{klass}"
          klass.instance
        end
    end

    def idiff
      IntegrationDiffRails::Dsl.idiff
    end
  end
end
