module Rapns
  module Daemon
    module Apns
      class DeliveryHandler < Rapns::Daemon::DeliveryHandler
        HOSTS = {
          :production  => ['gateway.push.apple.com', 2195],
          :development => ['127.0.0.1', 8888], # deprecated
          :sandbox     => ['gateway.sandbox.push.apple.com', 2195]
        }

        def initialize(app)
          @app = app
          @host, @port = HOSTS[@app.environment.to_sym]
        end

        def deliver(notification)
          unless @delivery_batcher
            @delivery_batcher = DeliveryBatcher.new(@app, connection)
            @delivery_batcher.start      
          end    

          @delivery_batcher.enqueue(notification)
        end

        def stopped
          @connection.close if @connection
          @delivery_batcher.stop if @delivery_batcher
        end

        protected

        def connection
          return @connection if defined? @connection
          connection = Connection.new(@app, @host, @port)
          connection.connect
          @connection = connection
        end
      end
    end
  end
end
