module IntegrationDiffRails
  module RSpec
    def idiff
      @idiff ||= IntegrationDiffRails::Runner.instance
    end
  end
end
