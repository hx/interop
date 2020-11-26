require 'interop/rpc/dispatcher'
require 'interop/rpc/controller'

module Hx
  module Interop
    # Contains RPC-specific classes.
    module RPC
      # An RPC server.
      class Server
        def initialize(connection)
          @connection = connection
          @dispatcher = Dispatcher.new
          @io_thread  = Thread.new { run }
        end

        # TODO: custom exception handler

        # Wait for the server to finish (i.e. for the connection to close).
        def wait
          @io_thread.join
          raise @error if @error # TODO: wrap in something specific, to preserve backtrace

          self
        end

        # @param [Message] event
        def send(event, *args)
          event = Message.build(event, *args)

          raise ArgumentError, 'Cannot send an event with an ID' if event.headers.key? Headers::ID

          @connection.write event
        end

        alias << send

        def on(criteria, *handler, &block)
          @dispatcher.on criteria, *handler, &block
          self
        end

        private

        def run
          @connection.read_all do |request|
            Thread.new do
              response = make_response(@dispatcher.match(request)&.call request)
              response[Headers::ID] = request[Headers::ID]
              @connection << response
            rescue StandardError => e
              @error = e
              @connection << Message.new(Headers::ERROR => "Unhandled exception: #{e}")
              @connection.close
            end
          end
        end

        def make_response(result)
          return result if result.is_a? Message

          result = [result] unless result.is_a? Array
          Message.build *result
        end
      end
    end
  end
end
