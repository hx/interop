module Hx::Interop
  describe Interceptor do
    let(:pipe) { Pipe.new }

    subject do
      described_class.new pipe do |message, w|
        w << message
        message          = message.dup
        message[:double] = 1
        w << message
      end
    end

    describe Interceptor::Read do
      it 'intercepts messages' do
        Thread.new do
          pipe << 'foobar'
          pipe.close
        end

        m = subject.read
        expect(m.body).to eq 'foobar'
        expect(m[:double]).to be nil

        m = subject.read
        expect(m.body).to eq 'foobar'
        expect(m['double']).to eq '1'

        expect { subject.read }.to raise_error EOFError
      end

      context 'with a message eater' do
        subject { described_class.new(pipe) { |_, _| } }

        it 'intercepts messages' do
          Thread.new do
            pipe << 'foobar'
            pipe.close
          end

          expect { subject.read }.to raise_error EOFError
        end
      end
    end

    describe Interceptor::Write do
      it 'intercepts messages' do
        Thread.new do
          subject << 'foobar'
          pipe.close
        end

        m = pipe.read
        expect(m.body).to eq 'foobar'
        expect(m[:double]).to be nil

        m = pipe.read
        expect(m.body).to eq 'foobar'
        expect(m['double']).to eq '1'

        expect { pipe.read }.to raise_error EOFError
      end

      context 'with a message eater' do
        subject { described_class.new(pipe) { |_, _| } }

        it 'intercepts messages' do
          Thread.new do
            subject << 'foobar'
            pipe.close
          end

          expect { pipe.read }.to raise_error EOFError
        end
      end
    end

    describe '.build' do
      let(:conn) { Connection.build StringIO.new, StringIO.new }

      it 'can build a connection' do
        int = described_class.build conn do
          read  { |m, w| w << m }
          write { |m, w| w << m }
        end
        expect(int).to be_a Connection
      end

      it 'can make a reader' do
        int = described_class.build do |b|
          b.read(conn) { |m, w| w << m }
        end
        expect(int).to be_an Interceptor::Read
      end

      it 'can make a writer' do
        int = described_class.build do |b|
          b.write(conn) { |m, w| w << m }
        end
        expect(int).to be_an Interceptor::Write
      end
    end
  end
end
