class Topic < ActiveRecord::Base
  has_site if respond_to? :has_site
  has_comments
  belongs_to :forum

  validates_presence_of :name
  validates_uniqueness_of :old_id, :allow_nil => true

  named_scope :bydate, :order => 'replied_at DESC'
  named_scope :imported, :conditions => "old_id IS NOT NULL"
  named_scope :stickyfirst, :order => "topics.sticky DESC, topics.replied_at DESC"
  named_scope :latest, lambda { |count|
    { :order => 'replied_at DESC', :limit => count }
  }
  named_scope :busiest, lambda { |count| {
    :select => "topics.*, count(posts.id) AS post_count", 
    :joins => "INNER JOIN posts ON posts.topic_id = topics.id",
    :group => column_names.map { |n| 'topics.' + n }.join(','),
    :order => "post_count DESC",
    :limit => count
  }}
  # adapted from the usual scope defined in has_groups, since here visibility is set at the forum level
  named_scope :visible_to, lambda { |reader| 
    conditions = "forums.id IS NULL OR pp.group_id IS NULL"
    if reader && reader.group_ids.any?
      ids = reader.group_ids
      conditions = ["#{conditions} OR pp.group_id IN(#{ids.map{"?"}.join(',')})", *ids]
    end
    {
      :joins => "LEFT OUTER JOIN forums on topics.forum_id = forums.id LEFT OUTER JOIN permissions as pp on pp.permitted_id = forums.id AND pp.permitted_type = 'Forum'",
      :conditions => conditions,
      :group => column_names.map { |n| self.table_name + '.' + n }.join(','),
      :readonly => false
    } 
  }

  def dom_id
    "topic_#{self.id}"
  end

  def visible_to?(reader=nil)
    if forum && !forum.visible_to?(reader)
      false
    elsif !reader && !Radiant::Config['forum.public?']
      false
    else
      true
    end
  end
  
  def reader
    posts.first.reader
  end
  
  def body
    posts.first.body
  end
    
  def title
    name
  end

end
