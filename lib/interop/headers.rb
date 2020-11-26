module Hx
  module Interop
    # Represents MIME headers for a message.
    class Headers
      ID             = 'Interop-Rpc-Id'.freeze
      CLASS          = 'Interop-Rpc-Class'.freeze
      ERROR          = 'Interop-Error'.freeze
      CONTENT_TYPE   = 'Content-Type'.freeze
      CONTENT_LENGTH = 'Content-Length'.freeze

      def initialize(headers = nil)
        @headers = {}
        merge! headers unless headers.nil?
      end

      def [](key)
        @headers[canonical_key key]
      end

      def []=(key, value)
        key = canonical_key(key)
        if value.nil?
          @headers.delete key
        else
          @headers[key] = value.to_s
        end
      end

      def merge!(*others)
        others.each do |other|
          other.each do |key, value|
            self[key] = value
          end
        end
        self
      end

      def merge(*others)
        dup.merge! others
      end

      def fetch(key, *args, &block)
        @headers.fetch canonical_key(key, *args, &block)
      end

      def dup
        headers = @headers.dup
        self.class.new.instance_exec do
          @headers = headers
          self
        end
      end

      def freeze
        @headers.freeze
        super
      end

      def inspect
        "<##{self.class.name} #{@headers.inspect[1..-2]}>"
      end

      def to_s
        map { |k, v| "#{k}: #{v}" }.join "\n"
      end

      private

      def method_missing(symbol, *args, &block)
        if @headers.respond_to? symbol
          @headers.__send__ symbol, *args, &block
        else
          super
        end
      end

      def respond_to_missing?(symbol, *)
        @headers.respond_to?(symbol) or super
      end

      def canonical_key(key)
        key
          .to_s
          .split(/[-_\s]+/)
          .map { |str| str[0].upcase + str[1..].downcase }
          .join('-')
      end
    end
  end
end
