module Hx
  module Interop
    # Anything from which you can read a message.
    module Reader
      def self.new(*args, &block)
        StreamReader.new *args, &block
      end

      # Read a message from the stream, blocking until a completed message is read.
      # @return [Message]
      def read
        _read
      end

      # Yields messages as they are read. Returns self when EOF is reached.
      # @return [Enumerable, Reader]
      # @yieldparam [Message]
      def read_all
        return enum_for :read_all unless block_given?

        loop do
          yield read
        rescue EOFError
          break
        end
        self
      end

      protected

      def _read
        raise NotImplementedError
      end
    end
  end
end
