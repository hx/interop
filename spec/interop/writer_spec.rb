module Hx::Interop
  describe Writer do
    let(:message) { Message.new }
    let(:target) { StringIO.new }
    let(:result) { target.tap(&:rewind).read }

    subject { described_class.new target }

    describe '#write' do
      it 'writes the given message to its stream' do
        message['foo'] = 'bar'
        message.body = 'foobar'
        subject.write message
        expect(result).to eq "Foo: bar\n\nfoobar\n"
      end
    end
  end
end
