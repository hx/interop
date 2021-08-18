require 'interop/connection'
require 'interop/rpc/dispatcher'
require 'interop/rpc/controller'

module Hx
  module Interop
    module RPC
      # Base class for RPC Client and Server
      class Base
        def initialize(reader, writer = reader)
          @connection = Connection.build(reader, writer)
          @dispatcher = Dispatcher.new
          yield self if block_given?
          @io_thread = Thread.new do
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

        def build_message(first, *rest)
          first = {Headers::CLASS => first} if first.is_a?(String) || first.is_a?(Symbol)
          Message.build first, *rest
        end

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
