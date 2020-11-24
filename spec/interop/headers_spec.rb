module Hx::Interop
  describe Headers do
    describe '#inspect' do
      before do
        subject['foo-bar'] = 'baz'
        subject['ONE_TWO'] = 'three'
      end

      it 'looks as expected' do
        expect(subject.inspect).to eq '<#Hx::Interop::Headers "Foo-Bar"=>"baz", "One-Two"=>"three">'
      end
    end
  end
end
