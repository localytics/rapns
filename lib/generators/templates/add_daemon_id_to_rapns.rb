class AddDaemonIdToRapns < ActiveRecord::Migration
  def self.up
    add_column :rapns_notifications, :daemon_id, :integer, :null => false, :default => 0
    add_column :rapns_apps, :daemon_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :rapns_notifications, :daemon_id
	remove_column :rapns_apps, :daemon_id    
  end
end
