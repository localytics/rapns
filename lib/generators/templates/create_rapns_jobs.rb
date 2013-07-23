class CreateRapnsJobs < ActiveRecord::Migration
  def self.up
    create_table :rapns_jobs do |t|
      t.integer     :job_id,                  :null => false
      t.integer     :daemon_id,               :null => false, :default => 0
      t.integer     :status,                  :default => 0, :limit => 1
      t.datetime    :status_changed_at,       :null => false
      t.datetime    :feedback_checked_at,     :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :rapns_jobs
  end
end
