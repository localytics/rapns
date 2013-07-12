class AddJobToRapns < ActiveRecord::Migration
  def self.up
    add_column :rapns_notifications, :job_id, :integer, :null => true
    add_column :rapns_apps, :job_id, :integer, :null => true
  end

  def self.down
    remove_column :rapns_notifications, :job_id
    remove_column :rapns_apps, :job_id
  end
end
