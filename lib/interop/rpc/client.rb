require 'interop/rpc/base'

module Hx
  module Interop
    # Contains RPC-specific classes.
    module RPC
      # An RPC client.
      class Client < Base
        attr_accessor :id_prefix

        def initialize(*)
          @next_id = 1
          @queues  = {}
          @mutex   = Mutex.new
          super
        end

        # @param [Message] request
        # @return [Message]
        def call(request, *args)
          request = build_message(request, *args)

          queue = Queue.new

          @mutex.synchronize do
            id = "#{id_prefix}#{@next_id}"
            @next_id += 1
            request[Headers::ID] = id
            @queues[id] = queue
          end

          write request

          queue.pop
        end

        alias [] call

        private

        def run
          super do |message|
            if (id = message[Headers::ID]) && (queue = @mutex.synchronize { @queues.delete id })
              queue << message
              queue.close
            else
              dispatcher << message
            end
          end
        end
      end
    end
  end
end
