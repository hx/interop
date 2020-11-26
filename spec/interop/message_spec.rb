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

    describe '#body=' do
      it 'treats hashes and arrays as JSON' do
        expect { subject.body = {foo: 'ü'} }
          .to change { subject.headers[Headers::CONTENT_TYPE] }
          .to Message::Types::JSON
        expect(subject.headers['Content-Length']).to eq '13' # 2 braces, 4 quotes, 1 colon, 3 ascii, 2 utf-8, 1 newline
        expect(subject.body).to eq %({"foo":"ü"}\n)
      end
    end
  end
end
