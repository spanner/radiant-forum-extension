module ForumSite

  def self.included(base)
    base.class_eval %{
      has_many :forums
      has_many :topics
      has_many :posts
    } 
    super
  end

end
