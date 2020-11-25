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

      # @param [Array<Message>] messages
      def write(*messages)
        @mutex.synchronize do
          messages.each do |message|
            message.headers.each do |k, v|
              @stream.puts "#{k}: #{v}"
            end
            @stream.puts
            @stream.write message.body
            @stream.puts
          end
        end
        self
      end
    end
  end
end
