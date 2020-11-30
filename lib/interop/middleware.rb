require 'interop/reader_writer'

module Hx
  module Interop
    # Base class for interop middleware.
    class Middleware
      include ReaderWriter

      # :nodoc:
      module BuildMessageOnWrite
        def write(*args)
          super Message.build(*args)
        end
      end

      def self.inherited(subclass)
        subclass.prepend BuildMessageOnWrite
        super
      end

      # @param [Array<Class>] classes
      # @param [ReaderWriter] connection
      def self.stack(*classes, connection)
        raise ArgumentError, "Expected an instance of #{ReaderWriter}" unless connection.is_a? ReaderWriter

        classes.reverse.reduce connection do |wrapped, klass|
          raise ArgumentError, "Expected subclasses of #{self}" unless klass.is_a?(Class) && klass < self

          klass.new(wrapped)
        end
      end

      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      # Return the complete Middleware stack as an array, with this instance as the first item, and
      # the core (or shallowest non-Middleware layer) as the last.
      def stack
        result = [self]
        if @connection.is_a? Middleware
          result.concat @connection.stack
        else
          result << @connection
        end
        result
      end

      protected

      def _read
        @connection.read
      end

      def _write(message)
        @connection.write message
      end
    end
  end
end
