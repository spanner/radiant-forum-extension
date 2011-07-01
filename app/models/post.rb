require 'sanitize'
class Post < ActiveRecord::Base
  has_site if respond_to? :has_site
  
  belongs_to :reader
  belongs_to :topic
  belongs_to :page
  has_many :attachments, :class_name => 'PostAttachment', :order => :position, :dependent => :destroy

  accepts_nested_attributes_for :topic
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  validates_presence_of :reader, :body

  before_save :update_search_text
  after_create :notify_holder_of_creation
  after_destroy :notify_holder_of_destruction

  default_scope :order => "posts.created_at DESC"
  named_scope :comments, :conditions => "page_id IS NOT NULL"
  named_scope :non_comments, :conditions => "page_id IS NULL"
  named_scope :imported, :conditions => "old_id IS NOT NULL"
  named_scope :in_topic, lambda { |topic| { :conditions => ["topic_id = ?", topic.id] }}
  named_scope :in_topics, lambda { |topics|
    ids = topics.map(&:id)
    { :conditions => ["topic_id IN (#{ids.map{"?"}.join(',')})", *ids] }
  }
  named_scope :from_reader, lambda { |reader| { :conditions => ["reader_id = ?", reader.id] }}
  named_scope :latest, lambda { |count| { :order => 'created_at DESC', :limit => count }}
  named_scope :except, lambda { |post| { :conditions => ["NOT posts.id = ?", post.id] }}
  named_scope :distinct_readers, :select => "DISTINCT posts.reader_id" do
    def count
      self.length  # replacing a SQL shortcut that omits the distinct clause
    end
  end
  # adapted from the usual scope defined in has_groups, since here visibility is set at the forum level
  named_scope :visible_to, lambda { |reader| 
    conditions = "topics.id IS NULL OR forums.id IS NULL OR pp.group_id IS NULL"
    if reader && reader.group_ids.any?
      ids = reader.group_ids
      conditions = ["#{conditions} OR pp.group_id IN(#{ids.map{"?"}.join(',')})", *ids]
    end
    {
      :joins => "INNER JOIN topics on posts.topic_id = topics.id LEFT OUTER JOIN forums on topics.forum_id = forums.id LEFT OUTER JOIN permissions as pp on pp.permitted_id = forums.id AND pp.permitted_type = 'Forum'",
      :conditions => conditions,
      :group => column_names.map { |n| self.table_name + '.' + n }.join(','),
      :readonly => false
    } 
  }
  named_scope :matching, lambda { |term|
    {
      :conditions => ["posts.search_text LIKE ?", "%#{stopped(term)}%"] 
    }
  }

  def self.in_forum(forum)
    in_topics(forum.topics)
  end

  def holder
    page || topic
  end
  
  def title
    holder.title if holder
  end
    
  def comment?
    !!page
  end
  
  def reply?
    !comment? && !first?
  end
  
  def page_when_paginated
    holder.page_for(self)
  end
  
  def forum
    topic.forum unless comment?
  end
  
  def first?
    !holder || holder.new_record? || holder.posts.first == self
  end

  def locked?
    holder && holder.locked?
  end
  
  def has_replies?
    holder.posts.last != self
  end
  
  def editable_interval
    Radiant::Config['forum.editable_period'].to_i.minutes if Radiant::Config['forum.editable_period']
  end
  
  def still_editable_for
    if editable_interval && still_editable?
      self.created_at + editable_interval - Time.now 
    else
      0
    end
  end
  
  def still_editable?
    !editable_interval || Time.now - self.created_at < editable_interval
  end
  
  def editable_by?(reader=nil)
    return false unless reader
    still_editable? && reader.id == reader_id
  end

  def visible_to?(reader=nil)
    if topic && !topic.visible_to?(reader)
      false
    elsif page && !page.visible_to?(reader)
      false
    elsif !reader && !Radiant::Config['forum.public?']
      false
    else
      true
    end
  end

  # so that page comments can be rendered from a radius tag
  def body_html
    if body
      html = RedCloth.new(body, [ :hard_breaks, :filter_html ]).to_html(:textile, :smilies)
      Sanitize.clean(html, Sanitize::Config::RELAXED)
    else
      ""
    end
  end
    
  def date_html
    self.created_at.to_s
  end
  
  def save_attachments(files=nil)
    files.collect {|file| self.attachments.create(:file => file) unless file.blank? } if files
  end

  def notify_holder_of_destruction
    holder.notice_destruction_of(self)
  end

  def notify_holder_of_creation
    holder.notice_creation_of(self)
  end

  def dom_id
    "post_#{self.id}"
  end

private

  # this is  rather crude, but it's database-agnostic, doesn't require 
  # any external indexing, and works well enough for most purposes.
  # for a more satisfactory search, tell sphinx to index the search_text field.

  def update_search_text
    self.search_text = self.class.stopped("#{self.title} #{self.body}")
  end

  def self.stopped(text="")
    stops = I18n.t('forum_extension.stopwords').split.join('|')
    text.downcase.gsub(/\b(#{stops})\b/, '').gsub(/(\W+)/, ' ')
  end

end
