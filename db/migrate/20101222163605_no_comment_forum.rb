class NoCommentForum < ActiveRecord::Migration
  def self.up
    Forum.find(:all, :conditions => "for_comments = 1").each {|forum| forum.destroy }
    remove_column :forums, :for_comments
  end

  def self.down
    add_column :forums, :for_comments, :boolean
  end
end
