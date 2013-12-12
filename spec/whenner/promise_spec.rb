module Whenner
  describe Promise do
    let(:deferred) { Deferred.new }
    subject(:promise) { deferred.promise }

    it 'has a value from the deferred' do
      deferred.fulfill(:a)
      expect(promise.value).to eql(:a)
    end

    it 'calls fulfillment callbacks when fulfilled' do
      resolved = false
      promise.done do
        resolved = true
      end
      expect { deferred.fulfill(:a) }.to change { resolved }.to(true)
    end

    it 'calls rejection callbacks when rejected' do
      resolved = false
      promise.fail do
        resolved = true
      end
      expect { deferred.reject(:a) }.to change { resolved }.to(true)
    end

    it 'calls always callbacks when resolved' do
      resolved = false
      promise.always do
        resolved = true
      end
      expect { deferred.fulfill(:a) }.to change { resolved }.to(true)
    end

    it 'passes fulfillment callbacks the value' do
      resolved = nil
      promise.done do |arg|
        resolved = arg
      end
      expect { deferred.fulfill(:a) }.to change { resolved }.to(:a)
    end

    it 'passes rejection callbacks the reason' do
      resolved = nil
      promise.done do |arg|
        resolved = arg
      end
      expect { deferred.fulfill(:a) }.to change { resolved }.to(:a)
    end

    it 'passes the value and reason to always callbacks' do
      promise.always do |value, reason|
        expect(value).to eql(:a)
        expect(reason).to be_nil
      end
      deferred.fulfill(:a)
    end

    it 'calls callbacks only once' do
      called = 0
      promise.done { called += 1 }
      deferred.fulfill(:a)
      deferred.fulfill(:b)
      expect(called).to eql(1)
    end

    it 'runs callbacks in order' do
      output = ''
      promise.done { output << 'a' }
      promise.done { output << 'b' }
      deferred.fulfill
      expect(output).to eql('ab')
    end

    it 'returns a new promise that fulfills to the value' do
      new_promise = promise.done { 'foo' }
      deferred.fulfill
      expect(new_promise.value).to eql('foo')
      expect(new_promise).to be_fulfilled
    end

    it 'returns a new promise that rejects to the reason' do
      new_promise = promise.fail { 'foo' }
      deferred.reject
      expect(new_promise.value).to eql('foo')
      expect(new_promise).to be_fulfilled
    end

    it 'returns a new promise that mimics a promise value' do
      d = Deferred.new
      new_promise = promise.done { d.promise }
      deferred.fulfill(:b)
      d.fulfill(:a)
      expect(new_promise.value).to eql(:a)
    end

    it 'is rejected on exception' do
      called = false
      promise.done { raise 'arg' }.fail { |e| called = e }
      deferred.fulfill
      expect(called).to be_a(RuntimeError)
    end
  end
end
