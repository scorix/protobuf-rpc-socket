module Protobuf
  module Rpc
    module Socket
      class Server

        def initialize(options)
          @options = options
        end

        def run
          config = ::Celluloid::Supervision::Configuration.new
          config.add(type: Protobuf::Rpc::Socket::Runner, as: :rpc, args: @options)

          begin
            loop { sleep 60 }
          rescue Interrupt
            exit
          end
        end

      end
    end
  end
end
