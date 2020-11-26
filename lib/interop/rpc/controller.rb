require 'interop/message'

module Hx
  module Interop
    module RPC
      # Abstract class for RPC server controllers.
      class Controller
        # TODO: hooks, error handlers

        def self.make_handler(action)
          action = action.to_sym

          unless public_instance_methods(false).include? action
            raise ArgumentError, "Invalid action '#{action}' on #{self}"
          end

          klass = self
          lambda do |message|
            controller = klass.new(message)
            controller.__send__ action
            controller.response
          end
        end

        attr_reader :request

        def initialize(request)
          @request = request
        end

        def response
          @response ||= Message.new
        end
      end
    end
  end
end
