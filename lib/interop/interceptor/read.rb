require 'interop/interceptor/base'
require 'interop/reader'

module Hx
  module Interop
    module Interceptor
      # Intercept reads
      # TODO: consider a background-processed version (like the Go version)
      class Read < Base
        include Reader

        # @param [Reader] reader
        def initialize(reader, &block)
          super
          @queue = []
          @mutex = Mutex.new
        end

        protected

        def _read
          @mutex.synchronize do
            @handler[@stream.read, @queue] while @queue.empty?
            @queue.shift
          end
        end
      end
    end
  end
end
