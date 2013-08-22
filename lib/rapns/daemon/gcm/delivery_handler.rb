module Rapns
  module Daemon
    module Gcm
      class DeliveryHandler < Rapns::Daemon::DeliveryHandler
        def initialize(app)
          @app = app
          @http = Net::HTTP::Persistent.new('rapns')
          @auth_key = Rapns.config.encryptor_key.present? ? @app.auth_key.decrypt : @app.auth_key
        end

        def deliver(notification)
          Rapns::Daemon::Gcm::Delivery.perform(@app, @auth_key, @http, notification)
        end

        def stopped
          @http.shutdown
        end
      end
    end
  end
end
