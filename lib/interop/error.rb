module Hx
  module Interop
    class Error < StandardError
      class Fatal < self
      end

      class InvalidHeader < Fatal
      end
    end
  end
end
