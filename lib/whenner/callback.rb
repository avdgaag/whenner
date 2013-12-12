module Whenner
  class Callback
    attr_reader :block, :deferred, :promise

    def initialize(block)
      @block    = block
      @deferred = Deferred.new
      @promise  = @deferred.promise
    end

    def call(*args)
      update_deferred(*args)
      promise
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
