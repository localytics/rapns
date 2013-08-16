module Rapns
  module Daemon
    class DeliveryHandler
      include Reflectable

      attr_accessor :queue

      def start
        @thread = Thread.new do
          loop do
            handle_next_batch
            break if @stop
          end
        end
      end

      def stop
        @stop = true
        if @thread
          queue.wakeup(@thread)
          @thread.join
        end
        stopped
      end

      protected

      def stopped
      end

      def handle_next_batch
        begin
          notifications = queue.pop(100)
        rescue DeliveryQueue::WakeupError
          Rapns.logger.error(e)
          return
        end

        begin
          deliver(notifications)
          notifications.each do |notification|
            reflect(:notification_delivered, notification)
          end
        rescue StandardError => e
          Rapns.logger.error(e)
          reflect(:error, e)
        ensure
          queue.batch_processed(notifications.length)
        end
      end
    end
  end
end
