module Rapns
  module Daemon
    module Apns
      class DeliveryBatcher
        include Reflectable
        include InterruptibleSleep

        SLEEP_INTERVAL = 0.1
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
          @queued_ids = []
          @mutex = Mutex.new
        end

        def start
          @stop = false

          @thread = Thread.new do
            loop do
              break if @stop
                begin
                  deliver_queue
                  check_for_error         
                  interruptible_sleep SLEEP_INTERVAL
                rescue Exception => e
                  puts e.inspect
                  puts e.backtrace
                end
            end
          end
        end

        def stop
          @stop = true
          interrupt_sleep
          @thread.join if @thread
        end

        def enqueue(notification)
          synchronize do
            if queued?(notification.id)
              Rapns.logger.info("[#{@app.name}] #{notification.id} was already sent, skipping")
            else
              @queued_ids << notification.id
              @queue << notification
            end
          end
        end

        protected

        def synchronize(&blk)
          @mutex.synchronize(&blk)
        end

        def queued?(id)
          @queued_ids.include?(id)        
        end

        def deliver_queue
          synchronize do
            processing = Array.new(@queue)
            if processing.length > 0
              ids = processing.map(&:id)
              Rapns.logger.info("[#{@app.name}] Marking #{processing.length} notifications delivered")
              Notification.update_all("delivered = 1", ["id IN (?)", ids])
              @queue = @queue - processing

              processing.each do |notification|
                @connection.write(notification.to_binary)   
                Rapns.logger.info("[#{@app.name}] #{notification.id} sent to #{notification.device_token}") 
              end          
            end
          end
        end

        def check_for_error
          if !@connection.closed? && @connection.select(SELECT_TIMEOUT)
            error = nil

            if tuple = @connection.read(ERROR_TUPLE_BYTES)
              cmd, code, notification_id = tuple.unpack("ccN")

              # TODO: mark the bad one as failed

              description = APN_ERRORS[code.to_i] || "Unknown error. Possible rapns bug?"
              error = Rapns::DeliveryError.new(code, notification_id, description)
            else
              error = Rapns::Apns::DisconnectionError.new
            end

            Rapns.logger.error("[#{@app.name}] Error received, reconnecting...")
            @connection.reconnect
          end
        end

      end
    end
  end
end
