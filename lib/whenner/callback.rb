module Whenner
  # A Callback is used internally by {Deferred} to store its callbacks.
  # It provides the same `call` interface as regular blocks, but this
  # will always return a promise for the block's return value.
  #
  # When the block in question returns a regular object, a new deferred for
  # that object is created and immediately fulfilled. When the block raises an
  # exception, the returned promise is rejected with that exception. When the
  # block returns a promise itself, the returned deferred will mimic that
  # promise -- as if that promise is what actually was returned.
  class Callback
    # A callable object, usually a Ruby block.
    #
    # @return [#call]
    attr_reader :block

    # @return [Deferred] the deferred object representing the block's return
    #   value.
    attr_reader :deferred

    def initialize(block)
      @block    = block
      @deferred = Deferred.new
    end

    # Run the block, passing it any given arguments, and return a promise
    # for its return value.
    #
    # @return [Promise]
    def call(*args)
      update_deferred(*args)
      deferred.promise
    end

    # @return [Promise] for this callback's {#deferred}.
    # @see #deferred
    def promise
      deferred.promise
    end

    private

    def update_deferred(*args)
      retval = block.call(*args)
      if retval.kind_of?(Promise)
        retval.done { |arg| deferred.fulfill(arg) }
        retval.fail { |arg| deferred.reject(arg) }
      else
        deferred.fulfill(retval)
      end
    rescue => e
      deferred.reject(e)
    end
  end
end
