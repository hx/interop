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

      # Yields messages as they are read. Returns when EOF is reached.
      # @return [Enumerable]
      # @yieldparam [Message]
      def read_all(&block)
        return enum_for :read_all unless block

        _read_all &block
      end

      protected

      def _read
        raise NotImplementedError
      end

      def _read_all
        raise NotImplementedError
      end
    end
  end
end
