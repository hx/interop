module Hx
  module Interop
    # Base class for StreamReader and StreamWriter
    class StreamAdapter
      # @param [IO, StringIO] stream
      def initialize(stream)
        if stream.is_a? IO
          stream.sync = true
          stream.binmode
        end

        @stream = stream
        @mutex  = Mutex.new
      end
    end
  end
end
