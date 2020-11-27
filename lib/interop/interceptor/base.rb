module Hx
  module Interop
    module Interceptor
      # Base class for read and write interceptors
      class Base
        def initialize(stream, &block)
          raise ArgumentError, 'Expected a block that takes exactly 2 arguments' unless [2, -1].include? block&.arity

          @stream  = stream
          @handler = block
        end
      end
    end
  end
end
