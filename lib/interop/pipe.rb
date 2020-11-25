require 'interop/channel'

module Hx
  module Interop
    # An object pipe. You can read exactly what is written to it.
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

      def write(*objects)
        @channel.put *objects
      end

      def close
        @channel.close
      end
    end
  end
end
