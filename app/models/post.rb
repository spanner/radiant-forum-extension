class Post < ActiveRecord::Base
  include WhiteListHelper
  
  is_site_scoped
  
  belongs_to :forum, :counter_cache => true
  belongs_to :reader,  :counter_cache => true
  belongs_to :topic, :counter_cache => true
  has_many :attachments, :class_name => 'PostAttachment', :order => :position, :dependent => :destroy
  
  attr_writer :name

  before_validation :set_reader
  before_create :set_forum
  after_create :set_topic_reply_data
  after_destroy :revert_topic_reply_data
  
  validates_presence_of :reader, :body, :topic
    
  def topic_page
    self.topic.page_for(self)
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :topic_title << :forum_name
    super
  end
  
  def dom_id
    "post_#{self.id}"
  end
  
  def first?
    self.topic.first_post == self
  end
  
  def has_replies?
    self.topic.last_post != self
  end
  
  def editable_interval
    Radiant::Config['forum.editable_period'].to_i.minutes if Radiant::Config['forum.editable_period']
  end
  
  def still_editable_for
    self.created_at + editable_interval - Time.now if editable_interval && still_editable?
  end
  
  def still_editable?
    !editable_interval || Time.now - self.created_at < editable_interval
  end
  
  def editable_by?(reader)
    still_editable? && reader && (reader.id == reader_id)
  end

  # special cases for page comments that need to be rendered from a radius tag
  
  def body_html
    white_list(RedCloth.new(self.body, [ :hard_breaks, :filter_html ]).to_html(:textile, :smilies)) if self.body
  end
    
  def date_html
    self.created_at.to_s(:html_date)
  end
  
  protected
  
    def set_reader
      self.reader ||= Reader.current_reader
    end
  
    def set_forum
      self.forum ||= self.topic.forum
    end
    
    def set_topic_reply_data
      self.topic.refresh_reply_data(self)
    end

    def revert_topic_reply_data
      self.topic.refresh_reply_data
    end
    
  
end
