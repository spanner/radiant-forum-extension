class ReaderMonitors < ActiveRecord::Migration
  def self.up
    rename_column :monitorships, :user_id, :reader_id
  end

  def self.down
    rename_column :monitorships, :reader_id, :user_id
  end
end
