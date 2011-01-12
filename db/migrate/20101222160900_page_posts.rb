class PagePosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :page_id, :integer
    Post.reset_column_information
    Post.all.each do |post|
      if topic = Topic.find_by_id(post.topic_id)
        if (topic.page_id)
          post.page_id = topic.page_id
          post.topic_id = nil
          post.save!
        end
      end
    end
    remove_column :topics, :page_id
  end

  def self.down
    remove_column :posts, :page_id
    add_column :topics, :page_id, :integer
  end
end
