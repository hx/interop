module Hx::Interop
  describe Middleware do
    let(:class_a) { Class.new described_class }

    let :class_b do
      Class.new described_class do
        def read
          message            = super.dup
          message['read-by'] = 'B'
          message
        end

        def write(message)
          message               = message.dup
          message['written-by'] = 'B'
          super message
        end
      end
    end

    let(:core) { Pipe.new 1 }

    after { core.close }

    describe '.stack' do
      it 'wraps zero or more middlewares around a ReaderWriter' do
        outer = Middleware.stack(class_a, class_b, core)
        expect(outer.stack).to match [instance_of(class_a), instance_of(class_b), core]
      end
    end

    it 'works as a no-op wrapper when read and write are not overridden' do
      conn = class_a.new(core)
      conn << 'hello'
      message = conn.read
      expect(message.body).to eq 'hello'
      expect(message.headers.keys).to eq ['Content-Length']
    end

    it 'allows read and write to be overridden' do
      conn = class_b.new(core)
      conn << 'hello'
      message = conn.read
      expect(message.body).to eq 'hello'
      expect(message.headers.to_h).to include 'Read-By' => 'B', 'Written-By' => 'B'
    end
  end
end
