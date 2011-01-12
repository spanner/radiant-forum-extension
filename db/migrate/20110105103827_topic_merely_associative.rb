class TopicMerelyAssociative < ActiveRecord::Migration
  def self.up
    remove_column :topics, :reader_id
    remove_column :topics, :posts_count
    remove_column :topics, :updated_by
    remove_column :topics, :created_by
    remove_column :topics, :updated_at
    remove_column :topics, :created_at
  end

  def self.down
    add_column :topics, :reader_id, :integer
    add_column :topics, :posts_count, :integer
    add_column :topics, :updated_at, :datetime
    add_column :topics, :created_at, :datetime
    add_column :topics, :updated_by, :integer
    add_column :topics, :created_by, :integer
  end
end
