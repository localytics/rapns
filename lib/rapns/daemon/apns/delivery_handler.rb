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
          unless @response_handler
            @response_handler = ResponseHandler.new(@app, connection)
            @response_handler.start      
          end    

          Rapns::Daemon::Apns::Delivery.perform(@app, connection, @response_handler, notification)
        end

        def stopped
          @connection.close if @connection
          @response_handler.stop if @response_handler
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
