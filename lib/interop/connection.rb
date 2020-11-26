require 'interop/stream_reader'
require 'interop/stream_writer'

module Hx
  module Interop
    # Combines a Reader and a Writer
    class Connection
      # @param [Reader, Pipe, IO, StringIO] reader
      # @param [Writer, Pipe, IO, StringIO] writer
      def initialize(reader, writer = reader)
        reader = StreamReader.new(reader) if reader.respond_to? :readline
        writer = StreamWriter.new(writer) if writer.respond_to? :puts

        @reader = reader
        @writer = writer
      end

      def read
        @reader.read
      end

      def read_all(&block)
        @reader.read_all &block
      end

      def write(*args)
        @writer.write *args
        self
      end

      alias << write

      def close
        @reader.close
        @writer.close
      end
    end
  end
end
