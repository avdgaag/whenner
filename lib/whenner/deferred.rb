module Whenner
  class Deferred
    attr_reader :promise

    def initialize
      @promise             = Promise.new(self)
      @state               = :pending
      @fulfilled_callbacks = []
      @rejected_callbacks  = []
      @always_callbacks    = []
    end

    def value
      raise UnresolvedError unless resolved?
      @value
    end

    def reason
      raise UnresolvedError unless resolved?
      @reason
    end

    def pending?
      state == :pending
    end

    def fulfilled?
      state == :fulfilled
    end

    def rejected?
      state == :rejected
    end

    def resolved?
      fulfilled? || rejected?
    end

    def fulfill(args = nil)
      raise CannotTransitionError if rejected?
      return if fulfilled?
      unless resolved?
        self.value = args
        resolve_to(:fulfilled)
      end
      self
    end

    def reject(args = nil)
      raise CannotTransitionError if fulfilled?
      return if rejected?
      unless resolved?
        self.reason = args
        resolve_to(:rejected)
      end
      self
    end

    def to_promise
      promise
    end

    def done(&block)
      cb = Callback.new(block)
      fulfilled_callbacks << cb
      cb.call(*callback_response) if fulfilled?
      cb.promise
    end

    def fail(&block)
      cb = Callback.new(block)
      rejected_callbacks << cb
      cb.call(*callback_response) if rejected?
      cb.promise
    end

    def always(&block)
      cb = Callback.new(block)
      always_callbacks << cb
      cb.call(*callback_response) if resolved?
      cb.promise
    end

    private

    attr_accessor :state
    attr_writer :value, :reason
    attr_reader :fulfilled_callbacks, :rejected_callbacks, :always_callbacks

    def resolve_to(state)
      self.state = state
      flush
    end

    def result_callbacks
      fulfilled? ? fulfilled_callbacks : rejected_callbacks
    end

    def callback_response
      fulfilled? ? value : reason
    end

    def flush
      (result_callbacks + always_callbacks).each do |cb|
        cb.call(callback_response)
      end
    end
  end
end
