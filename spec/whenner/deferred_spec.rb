module Whenner
  describe Deferred do
    it 'is pending by default' do
      expect(subject).to be_pending
    end

    context 'when pending' do
      it 'can be fulfilled' do
        subject.fulfill
        expect(subject).to be_fulfilled
      end

      it 'can be rejected' do
        subject.reject
        expect(subject).to be_rejected
      end

      it 'has no value' do
        expect { subject.value }.to raise_error
      end
    end

    context 'when fulfilled' do
      subject do
        described_class.new.tap { |d| d.fulfill }
      end

      it 'cannot transition to other states' do
        expect { subject.reject }.to raise_error
      end

      it 'has a value' do
        expect(subject.value).to be_nil
      end
    end

    context 'when rejected' do
      subject do
        described_class.new.tap { |d| d.reject(:foo) }
      end

      it 'cannot transition to other states' do
        expect { subject.fulfill }.to raise_error
      end

      it 'has a reason' do
        expect(subject.reason).to eql(:foo)
      end
    end

    it 'creates a promise' do
      expect(subject.promise).to be_kind_of(Promise)
    end

    context 'callbacks' do
      it 'calls fulfillment callbacks when fulfilled' do
        resolved = false
        subject.done { resolved = true }
        expect { subject.fulfill(:a) }.to change { resolved }.to(true)
      end

      it 'calls rejection callbacks when rejected' do
        resolved = false
        subject.fail { resolved = true }
        expect { subject.reject(:a) }.to change { resolved }.to(true)
      end

      it 'calls always callbacks when resolved' do
        resolved = false
        subject.always { resolved = true }
        expect { subject.fulfill(:a) }.to change { resolved }.to(true)
      end

      it 'passes fulfillment callbacks the value' do
        resolved = nil
        subject.done { |arg| resolved = arg }
        expect { subject.fulfill(:a) }.to change { resolved }.to(:a)
      end

      it 'passes rejection callbacks the reason' do
        resolved = nil
        subject.done { |arg| resolved = arg }
        expect { subject.fulfill(:a) }.to change { resolved }.to(:a)
      end

      it 'passes the value and reason to always callbacks' do
        subject.always do |value, reason|
          expect(value).to eql(:a)
          expect(reason).to be_nil
        end
        subject.fulfill(:a)
      end

      it 'calls callbacks only once' do
        called = 0
        subject.done { called += 1 }
        subject.fulfill(:a)
        subject.fulfill(:b)
        expect(called).to eql(1)
      end

      it 'runs callbacks in order' do
        output = ''
        subject.done { output << 'a' }
        subject.done { output << 'b' }
        subject.fulfill
        expect(output).to eql('ab')
      end

      it 'returns a new promise that fulfills to the value' do
        new_promise = subject.done { 'foo' }
        subject.fulfill
        expect(new_promise.value).to eql('foo')
        expect(new_promise).to be_fulfilled
      end

      it 'returns a new promise that rejects to the reason' do
        new_promise = subject.fail { 'foo' }
        subject.reject
        expect(new_promise.value).to eql('foo')
        expect(new_promise).to be_fulfilled
      end

      it 'returns a new promise that mimics a promise value' do
        d = Deferred.new
        new_promise = subject.done { d.promise }
        subject.fulfill(:b)
        d.fulfill(:a)
        expect(new_promise.value).to eql(:a)
      end

      it 'is rejected on exception' do
        called = false
        promise = subject.done { raise 'arg' }
        promise.fail { |e| called = e }
        subject.fulfill
        expect(called).to be_a(RuntimeError)
      end
    end
  end
end
