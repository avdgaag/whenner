module Whenner

  # Proxy object yielded by the {Deferred#then} method to set both `fail` and
  # `done` callbacks.
  class DeferredProxy
    def initialize(deferred)
      @deferred = deferred
    end

    def done(&block)
      @done = block if block_given?
      @done
    end

    def fail(&block)
      @fail = block if block_given?
      @fail
    end
  end
end
