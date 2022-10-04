module Hx
  module Interop
    # Allows blocking on running tasks
    class TaskGroup
      def initialize
        @count     = 0
        @mutex     = Mutex.new
        @condition = ConditionVariable.new
      end

      # Run the given block in a new thread. Calls to #wait will block until it has finished running.
      def run
        @mutex.synchronize { @count += 1 }
        Thread.new do
          yield
        ensure
          @mutex.synchronize do
            @count -= 1
            @condition.broadcast if @count.zero?
          end
        end
      end

      # Block until all threads created by #run have finished.
      def wait
        @mutex.synchronize do
          @condition.wait(@mutex) while @count.positive?
        end
      end
    end
  end
end
