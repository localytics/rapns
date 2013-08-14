module Rapns
  module Daemon
    module Apns
      class Delivery < Rapns::Daemon::Delivery
        def initialize(app, connection, response_handler, notification)
          @app = app
          @connection = connection
          @response_handler = response_handler
          @notification = notification
        end

        def perform
          if !@response_handler.queued?(@notification.id)
            @connection.write(@notification.to_binary)
            @response_handler.enqueue(@notification)   
            Rapns.logger.info("[#{@app.name}] #{@notification.id} sent to #{@notification.device_token}")
          else
            Rapns.logger.info("[#{@app.name}] #{@notification.id} was already sent, skipping")
          end
        end

      end
    end
  end
end
