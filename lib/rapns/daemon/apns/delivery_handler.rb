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

        def deliver(notifications)          
          unless Rapns.config.check_for_errors
            Rapns.logger.info("[#{@app.name}] Marking #{notifications.length} notifications delivered")
            Notification.update_all("delivered = 1", ["id IN (?)", notifications.map(&:id)])
          end

          notifications.each do |notification|
            Rapns::Daemon::Apns::Delivery.perform(@app, connection, notification)
          end
        end

        def stopped
          @connection.close if @connection
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
