module Hx
  module Interop
    # A collection of marshalers, with content-type strings, for decoding messages by content type.
    class ContentTypes < Hash
      def register(content_type, marshaler = nil)
        content_type = ContentType.new(content_type, marshaler) unless content_type.is_a? ContentType
        self << content_type
        content_type
      end

      def <<(content_type)
        content_type.is_a? ContentType or
          raise ArgumentError, "Expected an instance of #{ContentType}"
        key? content_type.name and
          raise ArgumentError, "Content type #{content_type.name} is already registered"
        self[content_type.name] = content_type
        self
      end

      def decode(message)
        delegate message[Headers::CONTENT_TYPE], :decode, message
      end

      # @!method load(content_type, str)
      # @!method dump(content_type, obj)
      # @!method encode(content_type, obj)
      # @!method encode_to(content_type, obj, message)
      %i[load dump encode encode_to].each do |name|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(content_type, *args)          # def load(content_type, *args)
            delegate content_type, :#{name}, *args  #   delegate content_type, :load, *args
          end                                       # end
        RUBY
      end

      def to_s
        keys.join ', '
      end

      private

      def delegate(content_type, *args)
        fetch(content_type) { raise Error::UnrecognisedContentType, 'Unrecognised content type' }.__send__ *args
      end
    end
  end
end
