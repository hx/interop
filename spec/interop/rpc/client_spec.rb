module Hx::Interop
  describe RPC::Client do
    let(:pipes) { 2.times.map { Pipe.new } }
    let(:server_conn) { Connection.new(pipes[0], pipes[1]) }
    let(:client_conn) { Connection.new(pipes[1], pipes[0]) }

    subject { described_class.new client_conn }

    context 'with normal shutdown' do
      after do
        pipes.each &:close
        subject.wait
      end

      it 'sends RPC requests' do
        subject.id_prefix = 'iddd'

        result = nil
        thread = Thread.new { result = subject.call 'foo' }

        expect(server_conn.read.headers.to_h).to eq(
          'Interop-Rpc-Id'    => 'iddd1',
          'Interop-Rpc-Class' => 'foo'
        )
        expect(thread.status).to eq 'sleep'
        server_conn.write 'Interop-Rpc-Id' => 'iddd1', foo: 'bar|'
        thread.join
        expect(result[:foo]).to eq 'bar|'
      end

      it 'dispatches events' do
        result = Queue.new
        subject.on('foo') { |message| result << message }
        server_conn.write 'Interop-Rpc-Class' => 'foo', 'woo' => 'hoo'
        expect(result.pop['woo']).to eq 'hoo'
      end

      describe '#magic' do
        it 'returns a magic proxy' do
          expect(subject).to receive(:call).once.with(:foo_bar, :baz)
          subject.magic.foo_bar :baz
        end

        it 'filters arguments through the given block' do
          json_client = subject.magic &Message.method(:json)
          expect(subject).to receive :call do |name, message|
            expect(name).to eq :do
            expect(message.body).to eq "[1,2,3]\n"
          end
          json_client.do [1, 2, 3]
        end
      end
    end

    context 'with an error in an event handler' do
      it 'raises on the waiting thread' do
        subject.on(/foo/) { raise 'ohmy' }
        server_conn.write 'Interop-Rpc-Class' => 'food'
        expect { subject.wait }.to raise_error RuntimeError, 'ohmy'
        pipes.each &:close
      end
    end
  end
end
