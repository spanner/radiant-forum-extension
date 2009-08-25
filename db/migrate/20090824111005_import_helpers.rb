class ImportHelpers < ActiveRecord::Migration
  def self.up
    add_column :readers, :old_id, :integer
    add_column :forums, :old_id, :integer
    add_column :topics, :old_id, :integer
    add_column :posts, :old_id, :integer
  end

  def self.down
    remove_column :readers, :old_id
    remove_column :forums, :old_id
    remove_column :topics, :old_id
    remove_column :posts, :old_id
  end
end
