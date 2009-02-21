class Post < ActiveRecord::Base
  is_site_scoped

  belongs_to :forum, :counter_cache => true
  belongs_to :reader,  :counter_cache => true
  belongs_to :topic, :counter_cache => true

  attr_writer :name

  before_validation :set_reader
  before_create :set_forum
  after_create :set_topic_reply_data
  after_destroy :revert_topic_reply_data
  
  validates_presence_of :reader, :body, :topic
  
  def editable_by?(reader)
    reader && (reader.id == reader_id)
  end
  
  def page
    self.topic.page_for(self)
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :topic_title << :forum_name
    super
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
