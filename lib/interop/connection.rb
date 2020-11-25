require 'interop/reader'
require 'interop/writer'

module Hx
  module Interop
    # Combines a Reader and a Writer
    class Connection
      # @param [Reader, Pipe, IO, StringIO] reader
      # @param [Writer, Pipe, IO, StringIO] writer
      def initialize(reader, writer = reader)
        reader = Reader.new(reader) if reader.respond_to? :readline
        writer = Writer.new(writer) if writer.respond_to? :puts

        @reader = reader
        @writer = writer
      end

      def read
        @reader.read
      end

      def read_all(&block)
        @reader.read_all &block
      end

      def write(*messages)
        @writer.write *messages
      end
    end
  end
end
