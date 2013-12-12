module Whenner
  describe Promise do
    let(:deferred)    { Deferred.new }
    subject(:promise) { deferred.promise }

    it 'converts into a promise as itself' do
      expect(promise.to_promise).to be(promise)
    end

    describe 'callbacks' do
      it 'can add done callbacks to the deferred' do
        expect { promise.done { :a } }.to change { deferred.send(:fulfilled_callbacks).size }.by(1)
      end

      it 'can add fail callbacks to the deferred' do
        expect { promise.fail { :a } }.to change { deferred.send(:rejected_callbacks).size }.by(1)
      end

      it 'can add always callbacks to the deferred' do
        expect { promise.always { :a } }.to change { deferred.send(:always_callbacks).size }.by(1)
      end
    end

    context 'when the deferred is fulfilled' do
      let(:deferred) { Deferred.new.fulfill(:a) }

      it 'has a value' do
        expect(promise.value).to eql(:a)
      end

      it 'knows its state' do
        expect(promise).to be_resolved
        expect(promise).to be_fulfilled
      end
    end


    context 'when the deferred is rejected' do
      let(:deferred) { Deferred.new.reject(:a) }

      it 'has a reason' do
        expect(promise.reason).to eql(:a)
      end

      it 'knows its state' do
        expect(promise).to be_resolved
        expect(promise).to be_rejected
      end
    end
  end
end
