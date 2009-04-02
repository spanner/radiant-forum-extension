class FirstPosts < ActiveRecord::Migration
  
  def self.up
    Topic.find(:all).each do |topic|
      topic.first_post = topic.posts.first
      topic.save
    end
  end

  def self.down
    
  end
end
