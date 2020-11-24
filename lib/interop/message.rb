require 'interop/headers'

module Hx
  module Interop
    # Represents a single interop message, with headers and a body.
    class Message
      attr_reader :headers, :body

      def initialize(headers = nil, body = nil)
        @headers = Headers.new(headers)
        @body    = body
      end
    end
  end
end
