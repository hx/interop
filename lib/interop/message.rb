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

      def self.json_parse_options
        @json_parse_options ||= {}
      end

      def self.build(*args)
        return args.first if args.first.is_a? Message

        new.tap do |message|
          args.each do |arg|
            case arg
            when nil
              # Ignore nils
            when Hash
              message.headers.merge! arg
            else
              message.body = arg.to_s
              message[Headers::CONTENT_LENGTH] = message.body.bytesize
            end
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
        # TODO: other types?
        case value
        when Hash, Array
          @body                             = JSON.generate(value) << "\n"
          @headers[Headers::CONTENT_TYPE]   = Types::JSON
          @headers[Headers::CONTENT_LENGTH] = @body.bytesize
        else
          @body = value.to_s
        end
      end

      def decode
        case @headers[Headers::CONTENT_TYPE]
        when Types::JSON
          return JSON.parse @body, self.class.json_parse_options
        end
        raise Error::NotDecodable, 'Message is not in a decodable format'
      end
    end
  end
end
