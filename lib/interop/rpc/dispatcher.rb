require 'interop/rpc/controller'

module Hx
  module Interop
    module RPC
      # Message dispatcher used by Client and Server.
      class Dispatcher
        Route = Struct.new :matcher, :handler do
          def call(*args)
            handler.call(*args)
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
          when Array, Set
            make_array_matcher criteria
          when Proc, Method
            criteria
          when String, Regexp
            -> message { criteria === message.headers[Headers::CLASS] }
          when Symbol
            make_matcher criteria.to_s
          else
            raise ArgumentError, 'Invalid message match criteria'
          end
        end

        def make_array_matcher(array)
          if array.all? { |item| item.is_a?(String) || item.is_a?(Symbol) }
            make_any_class_matcher Set.new(array.map(&:to_s)).freeze
          else
            make_any_matcher array.map(&method(:make_matcher))
          end
        end

        def make_any_class_matcher(classes)
          -> message { classes.include? message.headers[Headers::CLASS] }
        end

        def make_any_matcher(matchers)
          -> message { matchers.any? { |c| c.match? message } }
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
