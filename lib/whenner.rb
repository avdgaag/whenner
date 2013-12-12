require 'whenner/version'
require 'forwardable'

require 'whenner/conversions'
require 'whenner/callback'
require 'whenner/deferred'
require 'whenner/promise'

module Whenner
  WhennerError          = Class.new(StandardError)
  UnresolvedError       = Class.new(WhennerError)
  CannotTransitionError = Class.new(WhennerError)

  module_function

  def defer
    deferred = Deferred.new
    yield deferred
    deferred.promise
  end

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
