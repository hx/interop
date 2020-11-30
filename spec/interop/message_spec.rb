module Hx::Interop
  describe Message do
    describe '#decode' do
      it 'can decode JSON' do
        subject.headers['Content-Type'] = 'application/json'
        subject.body                    = '{"foo":"bar"}'

        expect(subject.decode).to eq 'foo' => 'bar'
      end

      it 'cannot decode other things' do
        subject.body = '{"foo":"bar"}'

        expect { subject.decode }.to raise_error Error::NotDecodable
      end
    end

    describe '.json' do
      it 'makes JSON messages' do
        message = described_class.json foo: 'ü'
        expect(message['Content-Type']).to eq 'application/json'
        expect(message['Content-Length']).to eq '13' # 2 braces, 4 quotes, 1 colon, 3 ascii, 2 utf-8, 1 newline
        expect(message.body).to eq %({"foo":"ü"}\n)
      end
    end
  end
end
