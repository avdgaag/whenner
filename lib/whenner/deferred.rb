module Whenner
  class Deferred
    attr_reader :promise

    def initialize
      @promise = Promise.new(self)
      @state = :pending
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

    private

    attr_accessor :state
    attr_writer :value, :reason

    def resolve_to(state)
      self.state = state
      promise.send :flush
    end
  end
end
