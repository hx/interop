require 'interop/message'

module Hx
  module Interop
    # Reads messages from a stream (e.g. STDIN)
    class Reader
      # @param [IO, StringIO] stream
      def initialize(stream)
        @stream = stream
        @mutex  = Mutex.new
      end

      # Read a message from the stream, blocking until a completed message is read.
      # @return [Message]
      def read
        @mutex.synchronize do
          headers = read_headers
          length  = headers[Headers::CONTENT_LENGTH]&.to_i
          body    =
            if length&.positive?
              @stream.read length
            elsif length.nil?
              read_paragraph
            else
              ''
            end
          Message.new(headers, body)
        end
      end

      # Yields messages as they are read. Returns when EOF is reached.
      # @return [Enumerable]
      # @yieldparam [Message]
      def read_all
        return enum_for :read_all unless block_given?

        loop do
          yield read
        rescue EOFError
          break
        end
      end

      private

      # @return [Hash]
      def read_headers
        read_paragraph.lines.to_h do |line|
          line.strip.split(/:\s*/).tap do |pair|
            raise Error::InvalidHeader unless pair.length == 2
          end
        end
      end

      def read_paragraph
        paragraph = @stream.gets('')
        raise EOFError if paragraph.nil?

        paragraph.sub /(\r?\n)\r?\n\z/, '\1'
      end
    end
  end
end
