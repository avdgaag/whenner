module Whenner
  # A deferred object is an operation that will eventually resolve to a result
  # value. A deferred can be in three possible states:
  #
  # * Pending: it has been created but not yet resolved.
  # * Fulfilled: it has been successfully resolved.
  # * Rejected: it has been unsuccessfully resolved.
  #
  # A deferred might transition from pending to fulfilled or rejected, but it
  # will not transition again once resolved (resolved can be either fulfilled
  # or rejected).
  #
  # When a deferred does resolve, it will trigger any applicable callbacks. You
  # can stack on callbacks on a deferred object before it has been resolved and
  # they will be called later. When you register callbacks on an already
  # resolved deferred, the callback will be called immediately. Note that a
  # callback will only be run once.
  #
  # When a callback is in the fulfilled state, it has a value that represents
  # its eventual outcome. When it is rejected, it has a reason.
  class Deferred
    # @return [Promise] a promise for this deferred
    attr_reader :promise

    def initialize
      @promise             = Promise.new(self)
      @state               = :pending
      @fulfilled_callbacks = []
      @rejected_callbacks  = []
      @always_callbacks    = []
    end

    # The value the deferred was resolved with.
    #
    # @raise [UnresolvedError] when the deferred is still pending
    def value
      raise UnresolvedError unless resolved?
      @value
    end

    # The reason the deferred was rejected.
    #
    # @raise [UnresolvedError] when the deferred is still pending
    def reason
      raise UnresolvedError unless resolved?
      @reason
    end

    # @return [Boolean] whether the deferred has not been resolved yet.
    def pending?
      state == :pending
    end

    # @return [Boolean] whether the deferred was successfully resolved.
    def fulfilled?
      state == :fulfilled
    end

    # @return [Boolean] whether the deferred was rejected.
    def rejected?
      state == :rejected
    end

    # @return [Boolean] whether the deferred was either fulfilled or rejected.
    def resolved?
      fulfilled? || rejected?
    end

    # Fulfill this promise with an optional value. The value will be stored in
    # the deferred and passed along to any registered `done` callbacks.
    #
    # When fulfilling a deferred twice, nothing happens.
    #
    # @raise [CannotTransitionError] when it was already fulfilled.
    # @return [Deferred] self
    def fulfill(value = nil)
      raise CannotTransitionError if rejected?
      return if fulfilled?
      unless resolved?
        self.value = value
        resolve_to(:fulfilled)
      end
      self
    end

    # Reject this promise with an optional reason. The reason will be stored in
    # the deferred and passed along to any registered `fail` callbacks.
    #
    # When rejecting a deferred twice, nothing happens.
    #
    # @raise [CannotTransitionError] when it was already fulfilled.
    # @return [Deferred] self
    def reject(reason = nil)
      raise CannotTransitionError if fulfilled?
      return if rejected?
      unless resolved?
        self.reason = reason
        resolve_to(:rejected)
      end
      self
    end

    # @return [Promise]
    def to_promise
      promise
    end

    # Register a callback to be run when the deferred is fulfilled.
    #
    # @yieldparam [Object] value
    # @return [Promise] a new promise representing the return value
    #   of the callback, or -- when that return value is a promise itself
    #   -- a promise mimicking that promise.
    def done(&block)
      cb = Callback.new(block)
      fulfilled_callbacks << cb
      cb.call(*callback_response) if fulfilled?
      cb.promise
    end

    # Register a callback to be run when the deferred is rejected.
    #
    # @yieldparam [Object] reason
    # @return [Promise] a new promise representing the return value
    #   of the callback, or -- when that return value is a promise itself
    #   -- a promise mimicking that promise.
    def fail(&block)
      cb = Callback.new(block)
      rejected_callbacks << cb
      cb.call(*callback_response) if rejected?
      cb.promise
    end

    # Register a callback to be run when the deferred is resolved.
    #
    # @yieldparam [Object] value
    # @yieldparam [Object] reason
    # @return [Promise] a new promise representing the return value
    #   of the callback, or -- when that return value is a promise itself
    #   -- a promise mimicking that promise.
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
