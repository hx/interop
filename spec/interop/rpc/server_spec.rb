module Hx::Interop
  describe RPC::Server do
    let(:pipes) { 2.times.map { Pipe.new } }
    let(:server_conn) { Connection.new(pipes[0], pipes[1]) }
    let(:client_conn) { Connection.new(pipes[1], pipes[0]) }

    subject { described_class.new server_conn }

    context 'with no error (graceful shutdown)' do
      after do
        client_conn.close
        subject.wait
      end

      context 'with simple handlers' do
        it 'sends response messages' do
          subject.on 'add' do |message|
            message['a'].to_i + message['b'].to_i
          end

          result = client_conn.write(Headers::CLASS => 'add', a: 3, b: 4).read

          expect(result.body).to eq '7'
        end
      end

      context 'with controller-based handlers' do
        let :klass do
          Class.new RPC::Controller do
            def add
              response.body = request.headers.reduce(0) { |sum, (key, value)| key.length == 1 ? sum + value.to_i : sum }
            end
          end
        end

        it 'sends the response from the controller' do
          subject.on 'add', klass, :add

          result = client_conn.write(Headers::CLASS => 'add', a: 3, b: 4, c: 9).read

          expect(result.body).to eq '16'
        end

        it 'does not allow private or inherited methods as actions' do
          expect { subject.on 'foo', klass, :to_s    }.to raise_error ArgumentError, /Invalid action 'to_s' on /
          expect { subject.on 'foo', klass, :request }.to raise_error ArgumentError, /Invalid action 'request' on /
        end
      end

      it 'can send events' do
        Thread.new { subject << Message.build(foo: 123) }
        expect(client_conn.read.headers.to_h).to eq 'Foo' => '123'
      end
    end

    context 'with an unhandled error' do
      it 'raises on the waiting thread' do
        subject.on('add') { raise 'foobar!' }
        result = client_conn.write(Headers::CLASS => 'add').read
        expect(result.headers.to_h).to eq 'Interop-Error' => 'Unhandled exception: foobar!'
        expect { subject.wait }.to raise_error RuntimeError, 'foobar!'
      end
    end
  end
end
