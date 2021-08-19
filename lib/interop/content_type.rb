require 'json'
require 'interop/marshaler'
require 'interop/content_types'

module Hx
  module Interop
    # A marshaler that corresponds to a content-type string.
    class ContentType
      attr_reader :name

      def initialize(name, marshaler)
        name.is_a? String or
          raise ArgumentError, 'Expected name to be a string'

        %i[load dump].all?(&marshaler.method(:respond_to?)) or
          raise ArgumentError, 'Expected marshaler to respond to :load and :dump'

        @name = -name
        @marshaler = marshaler
      end

      def load(str)
        @marshaler.load str
      end

      def dump(obj)
        @marshaler.dump obj
      end

      def decode(message)
        load message.body
      end

      def encode(obj)
        Message.new.tap { |m| encode_to obj, m }
      end

      def encode_to(obj, message)
        body         = dump(obj)
        message.body = body
        message.headers.merge!(
          Headers::CONTENT_TYPE   => name,
          Headers::CONTENT_LENGTH => body.bytesize
        )
      end

      STANDARD = ContentTypes.new
      JSON     = STANDARD.register('application/json', ::JSON)
      BINARY   = STANDARD.register('application/octet-stream', Marshaler::NULL)
      STANDARD.freeze
    end
  end
end
