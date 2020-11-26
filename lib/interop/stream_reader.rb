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
          length       = message.headers[Headers::CONTENT_LENGTH]&.to_i
          message.body =
            if length&.positive?
              @stream.read length
            elsif length.nil?
              read_paragraph.join
            else
              ''
            end
          message
        end
      end

      def _read_all
        loop do
          yield read
        rescue EOFError
          break
        end
      end

      private

      # @return [Hash]
      def read_headers
        read_paragraph.to_h do |line|
          line.strip.split(/:\s*/).tap do |pair|
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
    end
  end
end
