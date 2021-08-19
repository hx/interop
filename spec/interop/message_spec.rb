module Hx::Interop
  describe Message do
    describe '#decode' do
      it 'can decode JSON' do
        subject.headers['Content-Type'] = 'application/json'
        subject.body                    = '{"foo":"bar"}'

        expect(subject.decode(ContentType::STANDARD)).to eq 'foo' => 'bar'
      end

      it 'cannot decode other things' do
        subject.body = '{"foo":"bar"}'

        expect { subject.decode ContentType::STANDARD }.to raise_error Error::UnrecognisedContentType
      end
    end
  end
end
