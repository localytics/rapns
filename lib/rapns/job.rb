module Rapns
	class Job < ActiveRecord::Base
		self.table_name = 'rapns_jobs'

    if Rapns.attr_accessible_available?
      attr_accessible :campaign_id, :status, :status_changed_at, :daemon_id
    end

		has_one :app, :class_name => 'Rapns::App'
    has_many :notifications, :class_name => 'Rapns::Notification'

		before_create :set_status_changed_at_to_now

    scope :for_daemon_id, lambda { |daemon_id|
      where(daemon_id: daemon_id) 
    }

		def set_status_changed_at_to_now
	    self.status_changed_at = Time.now
	  end

	  def status=(value)
	    set_status_changed_at_to_now
	    write_attribute(:status, value)
	  end
	end

	module JobStatus
  	New = 0
  	Ready = 1
  	Sent = 2
  	Completed = 3
	end
end
