module Hx
  module Interop
    describe Channel do
      context 'with no buffer' do
        it 'queues things up' do
          thread = Thread.new { subject << :foo << :bar << :baz }
          expect(subject.get).to be :foo
          expect(subject.get).to be :bar
          expect(thread).to be_alive
          expect(subject.get).to be :baz
          thread.join
        end
      end

      context 'with a buffer' do
        subject { described_class.new 2 }

        it 'works as expected' do
          subject << :foo << :bar
          thread = Thread.new { subject << :baz }
          expect(subject.get).to be :foo
          expect(subject.get).to be :bar
          expect(thread).to be_alive
          expect(subject.get).to be :baz
          thread.join
        end
      end
    end
  end
end
