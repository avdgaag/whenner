require 'whenner/version'
require 'forwardable'

require 'whenner/conversions'
require 'whenner/deferred_proxy'
require 'whenner/callback'
require 'whenner/deferred'
require 'whenner/promise'

module Whenner
  # Generic root exception for the Whenner library. Any other custom
  # exceptions inherit from WhennerError.
  class WhennerError < StandardError; end

  # Custom exception raised when trying to access a deferred's value or
  # reason before it is resolved.
  #
  # @see WhennerError
  class UnresolvedError < WhennerError; end

  # Custom exception raised when trying to transition an already resolved
  # deferred.
  #
  # @see WhennerError
  class CannotTransitionError < WhennerError; end

  module_function

  # Create a new deferred, resolve it in the block and get its promise back.
  #
  # @yieldparam [Deferred] deferred
  # @return [Promise]
  def defer
    deferred = Deferred.new
    yield deferred
    deferred.promise
  end

  # Create a new deferred based that will resolve if/when the given promises
  # are resolved. Use to combine multiple promises into a single deferred
  # object.
  #
  # When all the given promises are fulfilled, the resulting promise from
  # `when` if fulfilled with an array of all the values. When one of the given
  # promises is rejected, the resulting promise is rejected with that reason.
  #
  # @param [Object] promises
  # @return [Promise]
  def when(*promises)
    defer do |d|
      promises.each_with_object([]) do |promise, values|
        Conversions.Promise(promise).tap do |p|
          p.done  do |value|
            values << value
            d.fulfill(values) if values.size == promises.size
          end
          p.fail do |reason|
            d.reject(reason)
          end
        end
      end
    end
  end
end
