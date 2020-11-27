require 'interop/interceptor/base'
require 'interop/writer'

module Hx
  module Interop
    module Interceptor
      # Intercept writes
      class Write < Base
        include Writer

        protected

        def _write(message)
          @handler[message, @stream]
        end
      end
    end
  end
end
