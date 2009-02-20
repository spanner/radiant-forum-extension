class Forum < ActiveRecord::Base
  acts_as_list
  order_by 'name'
  belongs_to :site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  validates_presence_of :name

  class << self
    def find_with_site(*args)
      # raise(MultiSite::SiteNotFound, "no site found", caller) unless current_site
      current_site.forums.find_without_site(*args)
    end
    alias_method_chain :find, :site
  end
  
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
  end

  has_many :posts, :order => 'posts.created_at desc' do
    def last
      @last_post ||= find(:first, :include => :user)
    end
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

  def self.current_site
    Page.current_site
  end
  
  def current_site
    self.class.current_site
  end

end
