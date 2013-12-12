module Whenner
  module Conversions
    module_function

    def Promise(arg)
      return arg.to_promise if arg.respond_to?(:to_promise)
      Deferred.new.fulfill(arg)
    end
  end
end
