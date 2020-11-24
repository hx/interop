module Hx::Interop
  describe Reader do
    let(:source) { <<~TEXT }
      Foo: bar
      other-foo: baz

      Howdy!

      Content-length: 4

      OMG
    TEXT

    subject { described_class.new StringIO.new(source) }

    describe '#read' do
      it 'correctly parses headers' do
        headers = subject.read.headers
        expect(headers).to be_a Headers
        expect(headers.to_h).to eq 'Foo' => 'bar', 'Other-Foo' => 'baz'
      end

      it 'correctly parses bodies without content-length' do
        expect(subject.read.body).to eq "Howdy!\n"
      end

      it 'parses bodies based on Content-Length' do
        subject.read
        message = subject.read
        expect(message.headers.to_h).to eq 'Content-Length' => '4'
        expect(message.body).to eq "OMG\n"
      end

      it 'raises past EOF' do
        subject.read
        subject.read
        expect { subject.read }.to raise_error EOFError
      end
    end

    describe '#read_all' do
      it 'reads all the messages' do
        all = subject.read_all.to_a
        expect(all.map &:body).to eq %W[Howdy!\n OMG\n]
      end
    end
  end
end
