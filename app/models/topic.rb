class Topic < ActiveRecord::Base
  is_site_scoped if defined? ActiveRecord::SiteNotFound

  belongs_to :forum, :counter_cache => true
  belongs_to :page
  belongs_to :reader
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  belongs_to :first_post, :class_name => 'Post', :include => :reader                                                # aka topic.body. should not change
  belongs_to :last_post, :class_name => 'Post', :include => :reader                                                 # this is just for display efficiency.
  belongs_to :replied_by, :class_name => 'Reader'                                                                   # this too.
  has_many :posts, :order => 'posts.created_at', :include => :reader, :dependent => :destroy do
    def last
      @last_post ||= find(:last)
    end
  end

  validates_presence_of :forum, :reader, :name
  validates_uniqueness_of :old_id, :allow_nil => true

  before_validation :set_reader
  before_create :set_defaults
  before_update :check_for_changing_forums
  before_validation_on_create :post_valid?
  after_create :save_post
  before_update :update_post
  
  attr_accessor :body

  named_scope :visible, {}
  named_scope :latest, lambda { |count|
    {
      :order => 'replied_at DESC',
      :limit => count
    }
  }

  def voice_count
    posts.count(:select => "DISTINCT reader_id")
  end
  
  def voices
    # TODO - move into sql
    posts.map { |p| p.reader }.uniq
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
    posts_count > (page ? 0 : 1)
  end
  
  def refresh_reply_data(post=nil)
    if !post && posts.empty?     # ie. the post has just been deleted and there are no others
      self.destroy
    elsif has_posts?
      post ||= posts.last
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

  def set_defaults
    self.sticky ||= 0
    self.locked ||= 0
  end

  def check_for_changing_forums
    old = Topic.find(id)
    if old.forum_id != forum_id
      set_posts_forum_id
      Forum.update_all ["posts_count = posts_count - ?", posts_count], ["id = ?", old.forum_id]
      Forum.update_all ["posts_count = posts_count + ?", posts_count], ["id = ?", forum_id]
    end
  end

  def set_posts_forum_id
    Post.update_all ['forum_id = ?', forum_id], ['topic_id = ?', id]
  end

  def post_valid?
    post = Post.new(:body => self.body, :reader => self.reader, :topic => self)
    unless post.valid?
      self.errors.add(:body, post.errors.on(:body))
      self.errors.add(:reader, post.errors.on(:reader))
      raise ActiveRecord::RecordInvalid.new(self)
    end
    true
  end

  def save_post
    self.first_post = self.posts.create!(:body => self.body, :created_at => self.created_at, :reader => self.reader)
    self.replied_at ||= Time.now();
    self.save(false)
  end
  
  def update_post
    post = self.first_post
    if !self.body.nil? && self.body != post.body
      post.body = self.body
      post.save!
    end
  rescue ActiveRecord::RecordInvalid => ow
    self.errors.add(:body, post.errors.on(:body))
    raise
  end

end
