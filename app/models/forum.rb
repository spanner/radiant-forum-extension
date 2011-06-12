class Forum < ActiveRecord::Base
  has_site if respond_to? :has_site
  has_groups
  
  has_many :topics, :dependent => :destroy

  default_scope :order => 'name ASC'
  named_scope :imported, :conditions => "old_id IS NOT NULL"
  validates_presence_of :name
  
  def dom_id
    "forum_#{self.id}"
  end
  
  # chains the visible_to? method created during the has_groups call.
  def visible_to_with_configuration?(reader=nil)
    Rails.logger.warn "Forum#visible_to_with_configuration?"
    return true if (reader || visible_by_default?) && visible_to_without_configuration?(reader)
  end
  alias_method_chain :visible_to?, :configuration
  
  def visible_by_default?
    !!Radiant.config['forum.public?']
  end

end
