class Topic < ActiveRecord::Base
  has_site if respond_to? :has_site

  belongs_to :forum, :counter_cache => true
  belongs_to :page
  belongs_to :reader
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  belongs_to :first_post, :class_name => 'Post'
  accepts_nested_attributes_for :first_post
                                                                                                                    
  belongs_to :last_post, :class_name => 'Post', :include => :reader
  belongs_to :replied_by, :class_name => 'Reader'
  has_many :posts, :order => 'posts.created_at ASC', :include => :reader, :dependent => :destroy do
    def last
      @last_post ||= find(:last)
    end
  end

  validates_presence_of :forum, :reader, :name
  validates_uniqueness_of :old_id, :allow_nil => true

  before_validation :set_reader
  before_validation :echo_inspection
  before_create :set_defaults
  after_create :capture_first_post
  
  attr_accessor :body

  default_scope :order => "replied_at DESC, created_at DESC"
  named_scope :latest, lambda { |count|
    {
      :order => 'replied_at DESC',
      :limit => count
    }
  }
  
  def replies
    page ? posts : posts.except(first_post)
  end

  def voice_count
    posts.count(:select => "DISTINCT reader_id")
  end
  
  def voices
    # TODO - move into sql
    posts.map { |p| p.reader }.uniq
  end
  
  def other_voices
    replies.map { |p| p.reader }.uniq
  end
    
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > posts_per_page end
  
  def posts_per_page
    ppp = Radiant::Config['forum.posts_per_page'] || 25
    ppp.to_i.to_f
  end
  
  def last_page
    (posts_count.to_f/posts_per_page).ceil.to_i
  end
  
  def page_for(post)
    return nil unless post.topic == self
    return 1 unless paged?
    (posts.index(post)/posts_per_page).ceil.to_i
  end

  def editable_by?(user)
    reader && (reader.id == reader_id)
  end
  
  def has_posts?
    replies.any?
  end
  
  def refresh_reply_data
    if post = posts.last
      self.last_post = post
      self.replied_by = post.reader
      self.replied_at = post.created_at
      self.save!
    end
  end
  
  def last_post_with_fetch
    if lp = last_post_without_fetch
      lp
    elsif has_posts? && lp = posts.last
      update_attribute(:last_post_id, lp.id)
      lp
    end
  end
  alias_method_chain :last_post, :fetch

  def dom_id
    "topic_#{self.id}"
  end
  
  def visible_to?(reader=nil)
    forum.visible_to?(reader)
  end
  
protected

  def set_reader
    self.reader ||= Reader.current
  end
  
  def echo_inspection
    Rails.logger.warn "+++ creating new topic: #{self.inspect}."
  end

  def set_defaults
    self.sticky ||= 0
    self.locked ||= 0
  end

  def capture_first_post
    self.first_post.topic = self
    self.first_post.save
  end
end
