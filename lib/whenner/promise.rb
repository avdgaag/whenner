module Whenner
  class Promise
    extend Forwardable

    def_delegators :@deferred, *%i[
      reason value fulfilled? resolved? rejected? fail done always
    ]

    def initialize(deferred)
      @deferred = deferred
    end

    def to_promise
      self
    end
  end
end
