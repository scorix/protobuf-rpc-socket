require 'celluloid/current'
require 'celluloid/io'

module Protobuf
  module Rpc
    module Socket
      class Server

        def initialize(options)
          @options = options
        end

        def run(supervision: true)
          if supervision
            config = ::Celluloid::Supervision::Configuration.new
            config.add(type: Protobuf::Rpc::Socket::Runner, as: :rpc, args: @options)
          else
            Protobuf::Rpc::Socket::Runner.new(@options)
          end

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
