class TopicMerelyAssociative < ActiveRecord::Migration
  def self.up
    remove_column :topics, :reader_id
    remove_column :topics, :first_post_id
    remove_column :topics, :last_post_id
    remove_column :topics, :posts_count
    remove_column :topics, :updated_by_id
    remove_column :topics, :created_by_id
  end

  def self.down
    add_column :topics, :reader_id, :integer
    add_column :topics, :first_post_id, :integer
    add_column :topics, :last_post_id, :integer
    add_column :topics, :posts_count, :integer
    add_column :topics, :updated_by_id, :integer
    add_column :topics, :created_by_id, :integer
  end
end
