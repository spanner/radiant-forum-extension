class Forum < ActiveRecord::Base
  has_site if respond_to? :has_site
  has_many :topics, :dependent => :destroy

  default_scope :order => 'name ASC'
  named_scope :imported, :conditions => "old_id IS NOT NULL"
  validates_presence_of :name
  
  # other extensions can attach chains here to limit access
  def self.visible_to(reader)
    self.scoped
  end
  
  def dom_id
    "forum_#{self.id}"
  end
  
  def visible_to?(reader=nil)
    return true if reader || Radiant::Config['forum.public?']
  end

end
