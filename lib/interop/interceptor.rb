require 'interop/connection'
require 'interop/interceptor/read'
require 'interop/interceptor/write'

module Hx
  module Interop
    # Module for building simple duplex interceptors
    module Interceptor
      # :nodoc:
      class Builder
        # @param [ReaderWriter, nil] connection
        def initialize(connection)
          @conn = connection
        end

        # @param [Reader] reader
        def read(reader = @conn, &block)
          raise 'Reader already declared' if @reader
          raise TypeError, 'Expected a Reader' unless reader.is_a? Reader

          @reader = Read.new(reader, &block)
        end

        # @param [Writer] writer
        def write(writer = @conn, &block)
          raise 'Reader already declared' if @writer
          raise TypeError, 'Expected a Writer' unless writer.is_a? Writer

          @writer = Write.new(writer, &block)
        end

        def build(&block)
          if block.arity.zero?
            instance_exec &block
          else
            block.call self
          end

          consolidate!

          return Connection.new @reader, @writer if @reader && @writer

          @reader || @writer || @conn or raise 'Nothing to build'
        end

        private

        def consolidate!
          @reader ||= @writer && @conn if @conn.is_a?(Reader)
          @writer ||= @reader && @conn if @conn.is_a?(Writer)
        end
      end

      # @param [ReaderWriter, nil] connection
      def self.build(connection = nil, &block)
        Builder.new(connection).build(&block)
      end
    end
  end
end
