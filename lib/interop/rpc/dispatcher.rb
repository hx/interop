require 'interop/rpc/controller'

module Hx
  module Interop
    module RPC
      # Message dispatcher used by Client and Server.
      class Dispatcher
        Route = Struct.new :matcher, :handler do
          def call(message)
            handler[message]
          end

          def match?(message)
            matcher[message]
          end
        end

        def initialize
          @routes = []
        end

        def on(criteria, *handler, &block)
          @routes << Route.new(
            make_matcher(criteria),
            make_handler(*handler, &block)
          )
        end

        def dispatch(message)
          @routes.each do |route|
            route.call message if route.match? message
          end
          self
        end

        def match(message)
          @routes.find { |r| r.match? message }
        end

        alias << dispatch

        private

        def make_matcher(criteria)
          case criteria
          when Proc
            criteria
          when String, Regexp
            -> message { criteria === message.headers[Headers::CLASS] }
          when Symbol
            make_matcher criteria.to_s
          else
            raise ArgumentError, 'Invalid message match criteria'
          end
        end

        def make_handler(*args, &block)
          return block if block && args.empty?

          if args.length == 2
            controller, action = args
            return controller.make_handler(action) if controller.is_a?(Class) && controller < Controller
          end

          raise ArgumentError, 'Invalid message handler'
        end
      end
    end
  end
end
