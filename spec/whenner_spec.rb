describe Whenner do
  describe '#defer' do
    it 'returns a new promise' do
      promise = Whenner.defer { 'bla' }
      expect(promise).to be_kind_of(Whenner::Promise)
    end

    it 'yields a deferred' do
      expect { |b| Whenner.defer(&b) }.to yield_with_args(Whenner::Deferred)
    end
  end

  describe '#when' do
    let(:deferred1) { Whenner::Deferred.new }
    let(:deferred2) { Whenner::Deferred.new }
    let!(:promise)  { Whenner.when(deferred1.promise, deferred2.promise) }

    it 'returns a promise' do
      expect(Whenner.when).to be_kind_of(Whenner::Promise)
      end

    it 'resolves when all given promises are resolved' do
      expect { deferred1.fulfill }.not_to change { promise.resolved? }.from(false)
      expect { deferred2.fulfill }.to change { promise.resolved? }.to(true)
    end

    it 'fulfills with all values' do
      deferred1.fulfill :a
      deferred2.fulfill :b
      expect(promise.value).to eql([:a, :b])
    end

    it 'rejects with the first reason' do
      deferred1.reject :a
      deferred2.reject :b
      expect(promise.reason).to eql(:a)
    end
    end
end
