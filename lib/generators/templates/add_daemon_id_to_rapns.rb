class AddDaemonIdToRapns < ActiveRecord::Migration
  def self.up
    add_column :rapns_notifications, :daemon_id, :string, :null => true
    add_column :rapns_apps, :daemon_id, :string, :null => true
  end

  def self.down
    remove_column :rapns_notifications, :daemon_id
	remove_column :rapns_apps, :daemon_id    
  end
end
