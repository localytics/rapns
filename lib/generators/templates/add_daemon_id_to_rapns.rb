class AddDaemonIdToRapns < ActiveRecord::Migration
  def self.up
    add_column :rapns_notifications, :daemon_id, :string, :null => true
    add_column :rapns_apps, :daemon_id, :string, :null => true
    add_index :rapns_notifications, :daemon_id, :name => "index_rapns_notifications_daemon_id"
  end

  def self.down
  	remove_index :rapns_notifications, :name => "index_rapns_notifications_daemon_id"
    remove_column :rapns_notifications, :daemon_id
	remove_column :rapns_apps, :daemon_id    
  end
end
