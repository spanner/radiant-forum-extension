class Forum < ActiveRecord::Base
  is_site_scoped
  order_by 'name'
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  validates_presence_of :name

  has_many :topics, :order => 'sticky desc, replied_at desc', :dependent => :destroy do
    def first
      @first_topic ||= find(:first)
    end
  end

  # this is used to see if a forum is "fresh"... we can't use .topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'Topic', :order => 'replied_at desc' do 
    def first 
      @first_recent_topic ||= find(:first) 
    end 
    def latest
      @latest_topics ||= find(:all, :limit => 5)
    end
  end

  has_many :posts, :order => 'posts.created_at desc' do
    def last
      @last_post ||= find(:first, :include => :user)
    end
    def latest
      @latest_posts ||= find(:all, :limit => 5)
    end
  end
  
  def dom_id
    "forum_#{self.id}"
  end
  
  def self.find_or_create_comments_forum
    @comments_forum = self.find_by_for_comments(true) || self.create(
      :name => 'Page Comments',
      :description => 'This forum automatically gathers up all comments on pages. You can reply here or on the page.',
      :created_by => User.find_by_admin(true),
      :position => 999,
      :created_at => Time.now,
      :for_comments => true
      )
  end
  
  def visible_to?(reader)
    # I might put some admin or user-only options in here
    reader && reader.is_a?(Reader)
  end

  # this is overriden
  def visible_by_default?
    true
  end

end
