require 'interop/channel'
require 'interop/message'

module Hx
  module Interop
    # A message pipe. You can read exactly what is written to it.
    class Pipe
      def initialize(buffer_size = 0)
        @channel = Channel.new(buffer_size)
      end

      def read
        @channel.get or raise EOFError
      end

      def read_all
        return enum_for :read_all unless block_given?

        while (obj = @channel.get)
          yield obj
        end
        self
      end

      def write(message, *args)
        @channel.put Message.build(message, *args)
      end

      alias << write

      def close
        @channel.close
      end
    end
  end
end
