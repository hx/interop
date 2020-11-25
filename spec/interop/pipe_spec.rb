module Hx::Interop
  describe Pipe do
    it 'passes objects from write to read' do
      obj = Object.new
      Thread.new { subject.write obj }
      expect(subject.read).to be obj
      subject.close
    end

    context 'with a buffer' do
      subject { described_class.new Float::INFINITY }

      it 'does not block writes' do
        subject.write 'foobar'
        expect(subject.read).to eq 'foobar'
        subject.close
      end
    end
  end
end
