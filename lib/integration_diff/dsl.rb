module IntegrationDiff
  module Dsl
    def self.idiff
      @idiff ||=
        begin
          klass =
            if IntegrationDiff.enable_service
              IntegrationDiff::Runner
            else
              IntegrationDiff::DummyRunner
            end

          IntegrationDiff.logger.info "Using runner #{klass}"
          klass.instance
        end
    end

    def idiff
      IntegrationDiff::Dsl.idiff
    end
  end
end
