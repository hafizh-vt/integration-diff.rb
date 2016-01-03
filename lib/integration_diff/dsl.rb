module IntegrationDiff
  module Dsl
    def self.idiff
      @idiff ||=
        begin
          klass =
            if IntegrationDiff.mock_service
              IntegrationDiff::DummyRunner
            else
              IntegrationDiff::Runner
            end

          Rails.logger.info "Using runner #{klass}"
          klass.instance
        end
    end

    def idiff
      IntegrationDiff::Dsl.idiff
    end
  end
end
