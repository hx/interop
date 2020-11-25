require 'interop/headers'

module Hx
  module Interop
    # Represents a single interop message, with headers and a body.
    class Message
      attr_reader :headers, :body

      def initialize(headers = nil, body = nil)
        @headers  = Headers.new(headers)
        self.body = body unless body.nil?
      end

      def body=(value)
        # TODO: other types?
        @body = value.to_s
        # @headers[Headers::CONTENT_LENGTH] = body.length
      end
    end
  end
end
