class ReaderOwnership < ActiveRecord::Migration
  
  # mostly for migrating old sites where users were talking
  # but also useful for admin moderation, probably
  # they already have created_at and updated_at
  
  def self.up
    Post.find(:all).each do |post|
      if Post.column_names.include?("user_id")
        post.created_by = User.find(post.user_id) rescue nil
      end
      post.reader ||= Reader.find_or_create_for_user(post.created_by)
      post.replied_by = Reader.find_or_create_for_user(post.replied_by_id)
      post.save
    end
  end

  def self.down
    
  end
end
