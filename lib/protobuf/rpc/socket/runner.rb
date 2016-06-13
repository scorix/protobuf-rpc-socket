# frozen-string-literal: true
require 'celluloid/current'
require 'celluloid/io'

module Protobuf
  module Rpc
    module Socket
      class Runner
        include Protobuf::Logging
        include ::Celluloid::IO

        finalizer :stop

        private

        attr_accessor :host, :port, :backlog, :pool_size
        attr_writer :running

        public

        attr_reader :running
        alias_method :running?, :running

        def initialize(*args)
          options = if args.first.is_a?(Hash)
                      args.first
                    elsif args.is_a?(Array)
                      Hash[args]
                    end
          @host = options.fetch(:host)
          @port = options.fetch(:port)
          @backlog = options.fetch(:backlog, 100)
          @pool_size = options.fetch(:pool_size, 5)

          if defined?(ActiveRecord::Base)
            ar_connection_pool_size = ActiveRecord::Base.connection_config[:pool]
            if ar_connection_pool_size < @pool_size
              logger.warn { "Pool size is changing to #{ar_connection_pool_size} as ActiveRecord::Base.connection_config[:pool] is #{ar_connection_pool_size}" }
              @pool_size = ar_connection_pool_size
            end
          end

          logger.debug { "Using middleware: Protobuf::ActiveRecord::Middleware::ConnectionManagement"}
          Protobuf::Rpc.middleware.use(Protobuf::ActiveRecord::Middleware::ConnectionManagement)
          logger.debug { "Using middleware: Protobuf::ActiveRecord::Middleware::QueryCache"}
          Protobuf::Rpc.middleware.use(Protobuf::ActiveRecord::Middleware::QueryCache)

          async.start
        end

        def start
          @running = true
          logger.info { sign_message("Starting Runner[#{Thread.current}], listening: #{host}:#{port}") }

          server = TCPServer.new(host, port)
          server.listen(backlog)

          pool = Connection.pool(size: @pool_size)

          while running? && (c = server.accept) do
            pool.async.handle(c)
          end
        end

        def stop
          @running = false
          logger.info { sign_message("Stopping Runner[#{Thread.current}]") }
        end
      end
    end
  end
end
