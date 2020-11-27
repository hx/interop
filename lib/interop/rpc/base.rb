require 'interop/rpc/dispatcher'
require 'interop/rpc/controller'

module Hx
  module Interop
    module RPC
      # Base class for RPC Client and Server
      class Base
        def initialize(connection)
          @connection = connection
          @dispatcher = Dispatcher.new
          @io_thread  = Thread.new do
            run
          rescue StandardError => e
            @error = e
          end
        end

        # TODO: custom exception handler?

        # Wait for the process to finish (i.e. for the connection to close).
        def wait
          @io_thread.join
          raise @error if @error # TODO: wrap in something specific, to preserve backtrace

          self
        end

        def on(criteria, *handler, &block)
          @dispatcher.on criteria, *handler, &block
          self
        end

        protected

        attr_reader :dispatcher

        def write(*args)
          @connection.write *args
        end

        def run
          @connection.read_all do |request|
            Thread.new do
              yield request
            rescue StandardError => e
              @io_thread.raise e
            end
          end
        end
      end
    end
  end
end
