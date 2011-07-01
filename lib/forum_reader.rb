module ForumReader

  def self.included(base)
    base.class_eval {
      has_many :posts, :order => 'posts.created_at desc', :dependent => :nullify
      
      named_scope :most_commenting, lambda { |count|
        {
          :select => "readers.*, count(posts.id) AS post_count", 
          :joins => "INNER JOIN posts ON posts.reader_id = readers.id",
          :group => "readers.id",
          :order => "post_count DESC",
          :limit => count
        }
      }
    }
  end
  
  # This will get more useful soon. For now I'm just establishing an interface.
  # Moderation will be a global flag but can also come from group-leadership or forum-ownership
  
  def is_moderator?(thing=nil)
    true if is_admin?
  end
end