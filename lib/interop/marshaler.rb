module Hx
  module Interop
    # Base class for message content marshalers.
    class Marshaler
      NULL = new

      def load(str)
        str
      end

      def dump(str)
        str
      end
    end
  end
end
