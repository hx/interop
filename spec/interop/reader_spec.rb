module Hx::Interop
  describe Reader do
    let(:source) { <<~TEXT }
      Foo: bar
      other-foo: baz

      Howdy!

      Content-length: 3

      OMG
      Content-Length: 2

      Hi
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
        expect(message.headers.to_h).to eq 'Content-Length' => '3'
        expect(message.body).to eq 'OMG'
      end

      it 'raises past EOF' do
        3.times { subject.read }
        expect { subject.read }.to raise_error EOFError
      end
    end

    describe '#read_all' do
      it 'reads all the messages' do
        all = subject.read_all.to_a
        expect(all.map &:body).to eq %W[Howdy!\n OMG Hi]
      end
    end

    context 'empty message bodies' do
      let(:source) { <<~TEXT }
        First-Message: is here


        Next-Message: is here

      TEXT

      it 'is readable' do
        message = subject.read
        expect(message.headers.to_h).to eq 'First-Message' => 'is here'
        expect(message.body).to eq ''

        expect { subject.read }.to raise_error EOFError
      end
    end

    context 'the end of a stream' do
      let(:source) { '' }

      it 'goes straight to EOF' do
        expect { subject.read }.to raise_error EOFError
      end
    end
  end
end
