require 'interop/stream_reader'
require 'interop/stream_writer'
require 'interop/reader_writer'

module Hx
  module Interop
    # Combines a Reader and a Writer
    class Connection
      include ReaderWriter

      # @param [Reader, IO, StringIO] reader
      # @param [Writer, IO, StringIO] writer
      def self.build(reader, writer = reader)
        return reader if reader.is_a?(ReaderWriter) && writer.equal?(reader)

        reader = StreamReader.new(reader) if reader.respond_to? :readline
        writer = StreamWriter.new(writer) if writer.respond_to? :puts

        new reader, writer
      end

      # @param [Reader] reader
      # @param [Writer] writer
      def initialize(reader, writer)
        raise ArgumentError, "Expected a #{Reader}" unless reader.is_a? Reader
        raise ArgumentError, "Expected a #{Writer}" unless writer.is_a? Writer

        @reader = reader
        @writer = writer
      end

      protected

      def _read
        @reader.read
      end

      def _write(message)
        @writer.write message
      end
    end
  end
end
