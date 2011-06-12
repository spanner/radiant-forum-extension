class DetachObserver < ActiveRecord::Migration
  def self.up
    remove_column :posts, :updated_by_id
    remove_column :posts, :created_by_id
  end

  def self.down
    add_column :posts, :updated_by_id, :integer
    add_column :posts, :created_by_id, :integer
  end
end
