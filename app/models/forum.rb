class Forum < ActiveRecord::Base
  has_site if respond_to? :has_site
  default_scope :order => 'name ASC'
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  validates_presence_of :name
  named_scope :visible, {}

  has_many :topics, :order => 'topics.sticky desc, topics.replied_at desc', :dependent => :destroy
  
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
  
  def dom_id
    "forum_#{self.id}"
  end
  
  def visible_to?(reader=nil)
    true
  end

end
