module Rapns
  module Daemon
    module Apns
      class ResponseHandler
        include Reflectable
        include InterruptibleSleep

        SLEEP_INTERVAL = 2
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

        def initialize(app, connection)
          @app = app
          @connection = connection
          @queue = []
          @completed = []
        end

        def start
          @stop = false

          @thread = Thread.new do
            loop do
              break if @stop
              Rapns.logger.info("calling mark_delivered")
              mark_delivered
              Rapns.logger.info("calling check_for_error")
              check_for_error         
              Rapns.logger.info("calling trim_queue")     
              trim_queue            
              interruptible_sleep SLEEP_INTERVAL
            end
          end
        end

        def stop
          @stop = true
          interrupt_sleep
          @thread.join if @thread
        end

        def enqueue(notification)
          #Rapns.logger.info("[#{@app.name}] #{notification.id} sent to #{notification.device_token}")
          @queue << notification
        end

        protected

        def mark_delivered
          Rapns.logger.info("in mark_delivered")
          processing = []
          processing.concat(@queue)
          Rapns.logger.info("processing queue size: " + processing.size)              
          Notification.update_all("delivered = 1", ["id IN ?", processing.map(&:id)])
          @completed << @working
          @queue = @queue - processing
        end

        def check_for_error
          if @connection.select(SELECT_TIMEOUT)
            error = nil

            if tuple = @connection.read(ERROR_TUPLE_BYTES)
              cmd, code, notification_id = tuple.unpack("ccN")

              # TODO: mark the bad one as failed
              #   arr.find_index {|item| item.seat_id == other.seat_id}

              # TODO: remove delivered from everything after the bad one in the queue

              # TODO: what's the rollback behavior for disconnects?

              description = APN_ERRORS[code.to_i] || "Unknown error. Possible rapns bug?"
              error = Rapns::DeliveryError.new(code, notification_id, description)
            else
              error = Rapns::Apns::DisconnectionError.new
            end

            Rapns.logger.error("[#{@app.name}] Error received, reconnecting...")
            @connection.reconnect
          end
        end

        def trim_queue
          if @completed.size > 2000
            @completed = @completed.drop(1000)
          end
        end

      end
    end
  end
end
