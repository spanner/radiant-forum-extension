module ForumSite

  def self.included(base)
    base.class_eval %{
      has_many :forums
      has_many :topics
      has_many :posts
      belongs_to :forum_layout, :class_name => 'Layout'
    } 
    super
  end
end
