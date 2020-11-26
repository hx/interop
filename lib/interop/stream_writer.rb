require 'interop/message'
require 'interop/writer'

module Hx
  module Interop
    # Writes messages to a stream (e.g. STDOUT)
    class StreamWriter
      include Writer

      # @param [IO, StringIO] stream
      def initialize(stream)
        @stream = stream
        @mutex  = Mutex.new
      end

      protected

      # @param [Message] message
      def _write(message)
        @mutex.synchronize do
          message.headers.each do |k, v|
            @stream.puts "#{k}: #{v}"
          end
          @stream.puts
          @stream.write message.body
          @stream.puts
        end
        self
      end
    end
  end
end
