module Rapns
  def self.apns_feedback
    Rapns.require_for_daemon
    Rapns::Daemon.initialize_store

    Rapns::Apns::App.for_daemon_id(Rapns.config.daemon_id).each do |app|
      receiver = Rapns::Daemon::Apns::FeedbackReceiver.new(app, 0)
      receiver.check_for_feedback
    end

    nil
  end
end
