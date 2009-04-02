class ReaderOwnership < ActiveRecord::Migration
  
  # mostly for migrating old sites where users were talking
  # but also useful for admin moderation, probably
  # they already have created_at and updated_at
  
  def self.up
    Post.find(:all).each do |post|
      if Post.column_names.include?("user_id")
        post.created_by = User.find(post.user_id) rescue nil
      end
      unless post.reader
        post.reader = Reader.find_or_create_for_user(post.created_by)
      end
      post.save
    end
    Topic.find(:all).each do |topic|
      if Topic.column_names.include?("user_id")
        topic.created_by = User.find(topic.user_id) rescue nil
      end
      unless topic.reader
        reader = Reader.find_or_create_for_user(topic.created_by)
        topic.reader = reader
      end
      unless topic.replied_by
        topic.replied_by = Reader.find_or_create_for_user(User.find(topic.replied_by_id)) rescue nil
      end
      topic.save
    end
  end

  def self.down
    
  end
end
