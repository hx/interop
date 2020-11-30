require 'json'

require 'interop/headers'

module Hx
  module Interop
    # Represents a single interop message, with headers and a body.
    class Message
      module Types
        JSON   = 'application/json'.freeze
        BINARY = 'application/octet-stream'.freeze
      end

      class << self
        def json_parse_options
          @json_parse_options ||= {}
        end

        def build(*args)
          return args.first if args.one? && args.first.is_a?(Message)

          new.tap do |message|
            args.each do |arg|
              assign_build_arg message, arg
            end
          end
        end

        def json(object, *args)
          build JSON.generate(object) << "\n", {Headers::CONTENT_TYPE => Types::JSON}, *args
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

      def decode
        case @headers[Headers::CONTENT_TYPE]
        when Types::JSON
          return JSON.parse @body, self.class.json_parse_options
        end
        raise Error::NotDecodable, 'Message is not in a decodable format'
      end

      def dup
        Message.new headers.to_h, body.dup
      end
    end
  end
end
