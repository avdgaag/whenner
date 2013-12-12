module Whenner
  # A promise represents the public face of a {Deferred} object. You can use it
  # to add more callbacks to the deferred or inspect its state -- but you
  # cannot resolve it.
  #
  # The methods and attributes of the promise are basically forwarded to the
  # deferred.
  class Promise
    extend Forwardable

    # @!attribute [r] fulfilled?
    #   @return [Boolean] whether the deferred was successfully resolved.
    # @!attribute [r] resolved?
    #   @return [Boolean] whether the deferred was either fulfilled or rejected.
    # @!attribute [r] rejected?
    #   @return [Boolean] whether the deferred was rejected.
    # @!attribute [r] pending?
    #   @return [Boolean] whether the deferred has not been resolved yet.
    # @!attribute [r] reason
    #   @return [Object] the reason for the deferred to be rejected.
    # @!attribute [r] value
    #   @return [Object] the value that the deferred was fulfilled with.
    # @!method fail(&block)
    #   Register a callback to fire when the deferred is rejected.
    #   @return [Promise] a new promise for the return value of the block.
    # @!method done(&block)
    #   Register a callback to fire when the deferred is fulfilled.
    #   @return [Promise] a new promise for the return value of the block.
    # @!method always(&block)
    #   Register a callback to fire when the deferred is resolved.
    #   @return [Promise] a new promise for the return value of the block.
    # @!method then(&block)
    #   Register both done and fail callbacks
    #   @return [Promise] a new promise for the return value the deferred
    def_delegators :@deferred, *%i[
      reason value pending? fulfilled? resolved? rejected?
      fail done always then
    ]

    def initialize(deferred)
      @deferred = deferred
    end

    def to_promise
      self
    end
  end
end
