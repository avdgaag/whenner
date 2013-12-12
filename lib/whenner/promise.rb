module Whenner
  class Promise
    extend Forwardable
    attr_reader :deferred
    attr_reader :fulfilled_callbacks, :rejected_callbacks, :always_callbacks
    private     :fulfilled_callbacks, :rejected_callbacks, :always_callbacks

    def_delegators :deferred, :value, :fulfilled?, :resolved?, :rejected?, :reason

    def initialize(deferred)
      @deferred            = deferred
      @fulfilled_callbacks = []
      @rejected_callbacks  = []
      @always_callbacks    = []
    end

    def done(&block)
      cb = Callback.new(block)
      fulfilled_callbacks << cb
      cb.call(*callback_response) if deferred.fulfilled?
      cb.promise
    end

    def fail(&block)
      cb = Callback.new(block)
      rejected_callbacks << cb
      cb.call(*callback_response) if deferred.rejected?
      cb.promise
    end

    def always(&block)
      cb = Callback.new(block)
      always_callbacks << cb
      cb.call(*callback_response) if deferred.resolved?
      cb.promise
    end

    def to_promise
      self
    end

    private

    def result_callbacks
      deferred.fulfilled? ? fulfilled_callbacks : rejected_callbacks
    end

    def callback_response
      deferred.fulfilled? ? value : reason
    end

    def flush
      (result_callbacks + always_callbacks).each do |cb|
        cb.call(callback_response)
      end
    end
  end
end
