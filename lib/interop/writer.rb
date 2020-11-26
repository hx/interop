require 'interop/message'

module Hx
  module Interop
    # Writes messages to a stream (e.g. STDOUT)
    class Writer
      # @param [IO, StringIO] stream
      def initialize(stream)
        @stream = stream
        @mutex  = Mutex.new
      end

      # @param [Message] message
      def write(message, *args)
        message = Message.build(message, *args)

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

      alias << write
    end
  end
end
