module IntegrationDiffRails
  class DummyRunner
    def self.instance
      @runner ||= DummyRunner.new
    end

    def start_run
    end

    def wrap_run
    end

    def screenshot(_)
    end
  end
end
