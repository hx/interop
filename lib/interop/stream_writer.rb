require 'interop/message'
require 'interop/writer'
require 'interop/stream_adapter'

module Hx
  module Interop
    # Writes messages to a stream (e.g. STDOUT)
    class StreamWriter < StreamAdapter
      include Writer

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
      end
    end
  end
end
