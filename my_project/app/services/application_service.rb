class ApplicationService
    def self.call(*args, **kwargs, &block)
        new(*args, **kwargs, &block).call
    end

    def call
        raise NotImplementedError, "#{self.class} must implement the call method"
    end
end