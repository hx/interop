require 'interop/rpc/base'

module Hx
  module Interop
    # Contains RPC-specific classes.
    module RPC
      # An RPC server.
      class Server < Base
        # @param [Message] event
        def send(event, *args)
          event = build_message(event, *args)

          raise ArgumentError, 'Cannot send an event with an ID' if event.headers.key? Headers::ID

          @connection.write event
        end

        alias << send

        private

        def run
          super do |request|
            response = make_response(dispatcher.match(request)&.call request, request[Headers::CLASS])
            response[Headers::ID] = request[Headers::ID]
            write response
          rescue StandardError => e
            write Headers::ERROR => "Unhandled exception: #{e}"
            raise
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
