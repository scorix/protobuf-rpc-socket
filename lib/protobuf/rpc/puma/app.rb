module Protobuf
  module Rpc
    module Puma
      class App

        include Protobuf::Logging

        def call(env, socket)
          req = socket.read(socket.gets('-').to_i)
          if req
            env = Protobuf::Rpc::Env.new(env.merge!('encoded_request' => req, 'log_signature' => log_signature))
            env = Protobuf::Rpc.middleware.call(env)
            res = env.encoded_response

            buffer = Protobuf::Rpc::Buffer.new(:write)
            buffer.set_data(res)
            socket.send(buffer.write, 0)
          end
        end

      end
    end
  end
end
