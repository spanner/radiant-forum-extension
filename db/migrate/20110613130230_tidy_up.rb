class TidyUp < ActiveRecord::Migration
  def self.up
    remove_column :forums, :topics_count
    remove_column :forums, :posts_count
    remove_column :forums, :site_id
    remove_column :forums, :reader_id
    remove_column :topics, :site_id
    remove_column :posts, :site_id
    remove_column :posts, :forum_id
  end

  def self.down
    add_column :forums, :topics_count, :integer
    add_column :forums, :posts_count, :integer
    add_column :forums, :site_id, :integer
    add_column :forums, :reader_id, :integer
    add_column :topics, :site_id, :integer
    add_column :posts, :site_id, :integer
    add_column :posts, :forum_id, :integer
  end
end
