module IntegrationDiffRails
  module Dsl
    def idiff
      @idiff ||= IntegrationDiffRails::Runner.instance
    end
  end
end
