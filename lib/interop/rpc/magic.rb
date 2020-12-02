module Hx
  module Interop
    module RPC
      # :nodoc:
      class Magic < BasicObject
        def initialize(receiver, symbol, &transformer)
          @receiver    = receiver
          @symbol      = symbol
          @transformer = transformer
        end

        private

        def method_missing(symbol, *args)
          args = [@transformer.call(*args)] if @transformer
          @receiver.__send__ @symbol, symbol, *args
        end

        def respond_to_missing?(*)
          true
        end
      end
    end
  end
end
