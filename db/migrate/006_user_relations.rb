class UserRelations < ActiveRecord::Migration
  
  # mostly for migrating old sites where users were talking
  # but also useful for admin moderation, probably
  # they already have created_at and updated_at
  
  def self.up
    add_column :posts, :created_by_id, :integer unless Post.column_names.include?("created_by_id")
    add_column :posts, :updated_by_id, :integer unless Post.column_names.include?("updated_by_id")
    add_column :topics, :created_by_id, :integer unless Topic.column_names.include?("created_by_id")
    add_column :topics, :updated_by_id, :integer unless Topic.column_names.include?("updated_by_id")
  end

  def self.down
    remove_column :posts, :created_by_id
    remove_column :posts, :updated_by_id
    remove_column :topics, :created_by_id
    remove_column :topics, :updated_by_id
  end
end
