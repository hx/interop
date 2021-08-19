module Hx
  module Interop
    class Error < StandardError
      class Fatal < self
      end

      class InvalidHeader < Fatal
      end

      class Unexpected < Fatal
      end

      class UnrecognisedContentType < self
      end
    end
  end
end
