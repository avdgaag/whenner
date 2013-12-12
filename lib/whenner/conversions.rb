module Whenner
  module Conversions
    module_function

    # Convert any object to a promise. When the object in question responds to
    # `to_promise`, the result of that method will be returned. If not, a new
    # deferred object is created and immediately fulfilled with the given
    # object.
    #
    # @param [Object] obj
    # @return [Promise]
    def Promise(obj)
      return obj.to_promise if obj.respond_to?(:to_promise)
      Deferred.new.fulfill(obj)
    end
  end
end
