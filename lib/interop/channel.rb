require 'interop/error'

module Hx
  module Interop
    # :nodoc:
    class Channel
      # :nodoc:
      class Blocker
        def initialize
          @queue = Queue.new
          @mutex = Mutex.new
        end

        def resolve
          @queue << nil
          @queue.close
          @value
        end

        def wait
          @mutex.synchronize do
            next unless @queue

            @queue.shift
            @queue = nil
          end
          @value
        end
      end

      # :nodoc:
      class Put < Blocker
        def initialize(value)
          @value = value
          super()
        end
      end

      # :nodoc:
      class Get < Blocker
        def resolve(value)
          @value = value
          super()
        end
      end

      Deadlock = Class.new(Error)
      Closed   = Class.new(Error)

      def initialize(butter_limit = 0)
        @buffer_limit = butter_limit
        @buffer       = []
        @gets         = []
        @puts         = []
        @mutex        = Mutex.new
      end

      def put(*objects)
        objects.each &method(:<<)
        self
      end

      def <<(obj)
        put = nil
        @mutex.synchronize do
          raise Closed if @closed

          if (get = @gets.shift)
            get.resolve obj
          elsif @buffer.length < @buffer_limit
            @buffer << obj
          else
            raise Deadlock if Thread.list.one?

            put = Put.new(obj)
            @puts << put
          end
        end
        put&.wait
        raise Closed if @closed

        self
      end

      def get
        get = nil
        @mutex.synchronize do
          return if @closed

          put = @puts.shift
          return put.resolve if put
          return @buffer.shift if @buffer.any?

          raise Deadlock if Thread.list.one?

          get = Get.new
          @gets << get
        end
        get.wait
      end

      def close
        raise Closed if @closed

        @mutex.synchronize do
          @closed = true
          @puts.each &:resolve
          @gets.each { |g| g.resolve nil }
        end
        @buffer
      end
    end
  end
end
