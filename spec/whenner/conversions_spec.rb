module Whenner
  describe '#Promise' do
    it 'returns a promise itself' do
      promise = Whenner::Deferred.new.promise
      expect(Whenner::Conversions.Promise(promise)).to be(promise)
    end

    it 'returns a promise for a deferred' do
      deferred = Whenner::Deferred.new
      expect(Whenner::Conversions.Promise(deferred)).to be(deferred.promise)
    end

    it 'returns a resolved promise for an object' do
      promise = Whenner::Conversions.Promise('foo')
      expect(promise.value).to eql('foo')
      expect(promise).to be_fulfilled
    end
  end
end
