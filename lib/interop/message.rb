require 'interop/headers'

module Hx
  module Interop
    # Represents a single interop message, with headers and a body.
    class Message
      class << self
        def build(*args)
          return args.first if args.one? && args.first.is_a?(Message)

          new.tap do |message|
            args.each do |arg|
              assign_build_arg message, arg
            end
          end
        end

        private

        def assign_build_arg(message, arg)
          case arg
          when nil
            # Ignore nils
          when Hash
            message.headers.merge! arg
          when Message
            message.headers.merge! arg.headers
            message.body = arg.body
          else
            message.body                     = arg.to_s
            message[Headers::CONTENT_LENGTH] = message.body.bytesize
          end
        end
      end

      attr_reader :headers, :body

      def initialize(headers = nil, body = nil)
        @headers  = Headers.new(headers)
        self.body = body unless body.nil?
      end

      def [](key)
        @headers[key]
      end

      def []=(key, value)
        @headers[key] = value
      end

      def body=(value)
        @body = value.to_s
      end

      # @param [ContentType, ContentTypes] decoder
      def decode(decoder)
        decoder.decode self
      end

      def dup
        Message.new headers.to_h, body.dup
      end
    end
  end
end
