require 'interop/message'
require 'interop/reader'

module Hx
  module Interop
    # Reads messages from a stream (e.g. STDIN)
    class StreamReader
      include Reader

      # Acceptable line terminators
      NEWLINES = Set.new(%W[\n \r\n]).freeze

      # @param [IO, StringIO] stream
      def initialize(stream)
        @stream = stream
        @mutex  = Mutex.new
      end

      protected

      def _read
        @mutex.synchronize do
          message      = Message.new(read_headers)
          length       = message.headers[Headers::CONTENT_LENGTH]
          message.body = length.nil? || length.empty? ? read_paragraph.join : read_length(length.to_i)
          message
        end
      end

      private

      # @return [Hash]
      def read_headers
        read_paragraph.to_h do |line|
          line.strip.split(/:\s*/, 2).tap do |pair|
            raise Error::InvalidHeader unless pair.length == 2
          end
        end
      end

      def read_paragraph
        lines = []
        while (line = @stream.readline("\n"))
          return lines if NEWLINES.include? line

          lines << line
        end
      end

      def read_length(length)
        result = length.positive? ? @stream.read(length) : ''
        sep    = @stream.read(1)
        sep    = @stream.read(1) if sep == "\r"
        raise Error::Unexpected, "Expected a newline after #{length} bytes" unless sep == "\n"

        result
      end
    end
  end
end
