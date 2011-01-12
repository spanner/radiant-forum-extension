class DetachObserver < ActiveRecord::Migration
  def self.up
    remove_column :posts, :updated_by
    remove_column :posts, :created_by
  end

  def self.down
    add_column :posts, :updated_by, :integer
    add_column :posts, :created_by, :integer
  end
end
