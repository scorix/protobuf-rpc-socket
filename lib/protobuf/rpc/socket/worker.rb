require 'celluloid/current'
require 'celluloid/io'

module Protobuf
  module Rpc
    module Socket
      class Worker
        include Protobuf::Logging
        include ::Celluloid

        def initialize(&complete_cb)
          @complete_cb = complete_cb
          @buffer = Protobuf::Rpc::Buffer.new(:write)
        end

        def handle(socket)
          data = read_data(socket)
          send_data(socket, handle_request(data)) if data
        end

        def read_data(socket)
          socket.recv(socket.gets('-').to_i)
        end

        def send_data(socket, data)
          @buffer.set_data(data)
          socket.send(@buffer.write, 0)
          reset_buffer
          @complete_cb.call(socket) if @complete_cb
        end

        def reset_buffer
          @buffer.size = 0
          @buffer.data = ''
          @buffer.instance_variable_set(:@flush, false)
        end

        private
        # Invoke the service method dictated by the proto wrapper request object
        #
        def handle_request(request_data)
          # Create an env object that holds different parts of the environment and
          # is available to all of the middlewares
          env = Protobuf::Rpc::Env.new('encoded_request' => request_data, 'log_signature' => log_signature)

          # Invoke the middleware stack, the last of which is the service dispatcher
          env = Protobuf::Rpc.middleware.call(env)

          env.encoded_response
        end
      end
    end
  end
end
