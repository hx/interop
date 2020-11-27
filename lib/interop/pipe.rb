require 'interop/channel'
require 'interop/message'
require 'interop/reader'
require 'interop/writer'

module Hx
  module Interop
    # A message pipe. You can read exactly what is written to it.
    class Pipe
      include Reader, Writer

      def initialize(buffer_size = 0)
        @channel = Channel.new(buffer_size)
      end

      def close
        @channel.close
      end

      protected

      def _read
        @channel.get or raise EOFError
      end

      def _write(message)
        @channel.put message
      end
    end
  end
end
