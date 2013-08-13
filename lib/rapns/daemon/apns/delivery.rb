module Rapns
  module Daemon
    module Apns
      class Delivery < Rapns::Daemon::Delivery
        SELECT_TIMEOUT = 0.2
        ERROR_TUPLE_BYTES = 6
        APN_ERRORS = {
          1 => "Processing error",
          2 => "Missing device token",
          3 => "Missing topic",
          4 => "Missing payload",
          5 => "Missing token size",
          6 => "Missing topic size",
          7 => "Missing payload size",
          8 => "Invalid token",
          255 => "None (unknown error)"
        }

        def initialize(app, connection, response_handler, notification)
          @app = app
          @connection = connection
          @response_handler = response_handler
          @notification = notification
        end

        def perform
          begin
            @connection.write(@notification.to_binary)
            @response_handler.enqueue(@notification)
          end
        end

        protected

        def check_for_error
          if @connection.select(SELECT_TIMEOUT)
            error = nil

            if tuple = @connection.read(ERROR_TUPLE_BYTES)
              cmd, code, notification_id = tuple.unpack("ccN")

              description = APN_ERRORS[code.to_i] || "Unknown error. Possible rapns bug?"
              error = Rapns::DeliveryError.new(code, notification_id, description)
            else
              error = Rapns::Apns::DisconnectionError.new
            end

            begin
              Rapns.logger.error("[#{@app.name}] Error received, reconnecting...")
              @connection.reconnect
            ensure
              raise error if error
            end
          end
        end
      end
    end
  end
end
