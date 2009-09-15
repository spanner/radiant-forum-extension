module ForumReader

  def self.included(base)
    base.class_eval {
      has_many :topics, :dependent => :nullify
      has_many :posts, :order => 'posts.created_at desc', :dependent => :nullify
    }
  end
end