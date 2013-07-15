module Rapns
	class Job < ActiveRecord::Base
		self.table_name = 'rapns_jobs'

    if Rapns.attr_accessible_available?
      attr_accessible :campaign_id, :status, :status_changed_at
    end

    attr_readonly :daemon_id
		before_create :set_daemon_id

		has_one :app, :class_name => 'Rapns::App'
    has_many :notifications, :class_name => 'Rapns::Notification'

		before_create :set_status_changed_at_to_now

    scope :for_current_daemon, -> { 
      where(daemon_id: Rapns.config.daemon_id) 
    }

		def set_status_changed_at_to_now
	    self.status_changed_at = Time.now
	  end

	  def set_daemon_id
	  	write_attribute(:daemon_id, Rapns.config.daemon_id)
	  end

	  def status=(value)
	    set_status_changed_at_to_now
	    write_attribute(:status, value)
	  end
	end
end
