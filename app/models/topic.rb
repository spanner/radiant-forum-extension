class Topic < ActiveRecord::Base
  has_site if respond_to? :has_site
  include PostHolder    # lib/post_holder.rb holds functionality shared with Pages and perhaps other commentable objects
  
  belongs_to :forum
  belongs_to :replied_by, :class_name => 'Reader'
  has_many :posts, :order => 'posts.created_at ASC', :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :old_id, :allow_nil => true
  
  default_scope :order => "topics.sticky DESC, topics.replied_at DESC"
  
  named_scope :latest, lambda { |count|
    { :order => 'replied_at DESC', :limit => count }
  }

  def dom_id
    "topic_#{self.id}"
  end

  def visible_to?(reader=nil)
    return true if reader || Radiant::Config['forum.public?']
  end
  
  def reader
    posts.first.reader
  end
  
  def body
    posts.first.body
  end

protected

  def refresh_reply_data
    if post = posts.last
      self.replied_by = post.reader
      self.replied_at = post.created_at
      self.save
    end
  end

end
