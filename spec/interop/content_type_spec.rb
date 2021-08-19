module Hx::Interop
  describe ContentType do
    describe described_class::STANDARD do
      it 'can encode JSON messages' do
        message = subject.encode 'application/json', foo: 'ü'
        expect(message['Content-Type']).to eq 'application/json'
        expect(message['Content-Length']).to eq '12' # 2 braces, 4 quotes, 1 colon, 3 ascii, 2 utf-8
        expect(message.body).to eq %({"foo":"ü"})
      end
    end
  end
end
