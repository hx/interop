require 'interop/message'

module Hx
  module Interop
    # Anything to which you can write a message
    module Writer
      def self.new(*args, &block)
        StreamWriter.new(*args, &block)
      end

      # @param [Message] message
      def write(message, *args)
        _write Message.build(message, *args)
        self
      end

      def <<(*args)
        write *args
      end

      protected

      def _write(*)
        raise NotImplementedError
      end
    end
  end
end
