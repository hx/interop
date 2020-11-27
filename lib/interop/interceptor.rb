require 'interop/connection'
require 'interop/interceptor/read'
require 'interop/interceptor/write'

module Hx
  module Interop
    # Module for building simple duplex interceptors
    module Interceptor
      # :nodoc:
      class Builder
        def initialize(stream)
          @stream = stream
        end

        def read(reader = @stream, &block)
          raise 'Reader already declared' if @reader
          raise TypeError, 'Expected a Reader' unless reader.is_a? Reader

          @reader = Read.new(reader, &block)
        end

        def write(writer = @stream, &block)
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

          @reader ||= @writer && @stream if @stream.is_a?(Reader)
          @writer ||= @reader && @stream if @stream.is_a?(Writer)

          return Connection.new @reader, @writer if @reader && @writer

          @reader || @writer || @stream or raise 'Nothing to build'
        end
      end

      def self.build(stream = nil, &block)
        Builder.new(stream).build(&block)
      end
    end
  end
end
