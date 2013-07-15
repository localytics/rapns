module Rapns
  module Daemon
    class Feeder
      extend InterruptibleSleep
      extend Reflectable

      def self.start
        @stop = false

        if Rapns.config.embedded
          Thread.new { feed_forever }
        elsif Rapns.config.push
          enqueue_notifications
        else
          feed_forever
        end
      end

      def self.stop
        @stop = true
        interrupt_sleep
      end

      protected

      def self.feed_forever
        loop do
          enqueue_notifications
          interruptible_sleep(Rapns.config.push_poll)
          break if stop?
        end
      end

      def self.stop?
        @stop
      end

      def self.enqueue_notifications
        begin
          idle = Rapns::Daemon::AppRunner.idle.map(&:app)

          source = Rapns::Notification.ready_for_delivery.for_apps(idle)
          source = source.for_daemon_id(Rapns.config.daemon_id)

          source.each do |notification|
            Rapns::Daemon::AppRunner.enqueue(notification)
            reflect(:notification_enqueued, notification)
          end
        rescue StandardError => e
          Rapns.logger.error(e)
          reflect(:error, e)
        end
      end
    end
  end
end
