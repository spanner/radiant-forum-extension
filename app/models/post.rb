class Post < ActiveRecord::Base
  belongs_to :forum, :counter_cache => true
  belongs_to :reader,  :counter_cache => true
  belongs_to :topic, :counter_cache => true

  before_create { |r| r.forum_id = r.topic.forum_id }
  after_create  { |r| Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.reader_id, r.id], ['id = ?', r.topic_id]) }
  after_destroy { |r| t = Topic.find(r.topic_id) ; Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.posts.last.created_at, t.posts.last.reader_id, t.posts.last.id], ['id = ?', t.id]) if t.posts.last }

  validates_presence_of :reader, :body, :topic
  attr_accessible :body
  
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
end
