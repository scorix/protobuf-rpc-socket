require 'celluloid/current'

module Protobuf
  module Rpc
    module Socket
      class Connection
        include Protobuf::Logging
        include Celluloid

        finalizer :stop

        delegate :handle, to: :@worker

        def initialize
          @worker = Worker.new(&:close)
          logger.debug { sign_message("Initializing Connection[#{Thread.current}]") }
        end

        def stop
          logger.debug { sign_message("Stopping Connection[#{Thread.current}]") }
        end
      end
    end
  end
end
