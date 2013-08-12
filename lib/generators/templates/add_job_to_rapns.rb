class AddJobToRapns < ActiveRecord::Migration
  def self.up
    add_column :rapns_notifications, :job_id, :integer, :null => true
    add_column :rapns_apps, :job_id, :integer, :null => true
    add_index :rapns_notifications, [:job_id, :device_token], :unique => true, :name => "index_rapns_notifications_unique_apns"
  	add_index :rapns_notifications, [:job_id, :registration_ids], :unique => true, :name => "index_rapns_notifications_unique_gcm", :length => {:registration_ids => 250}
  end

  def self.down
  	remove_index :rapns_notifications, :name => "index_rapns_notifications_unique_gcm"
    remove_index :rapns_notifications, :name => "index_rapns_notifications_unique_apns"
    remove_column :rapns_apps, :job_id
    remove_column :rapns_notifications, :job_id
  end
end
