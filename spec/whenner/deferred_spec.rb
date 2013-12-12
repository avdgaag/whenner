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
  end
end
