module IntegrationDiffRails
  module RSpec
    def idiff
      @idiff ||= IntegrationDiffRails.runner
    end
  end
end
