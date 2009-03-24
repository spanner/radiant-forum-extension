class Topic < ActiveRecord::Base
  is_site_scoped

  belongs_to :forum, :counter_cache => true
  belongs_to :page
  belongs_to :reader

  belongs_to :first_post, :class_name => 'Post', :include => :reader                                                # aka topic.body. should not change
  belongs_to :last_post, :class_name => 'Post', :include => :reader                                                 # this is just for display efficiency.
  belongs_to :replied_by, :class_name => 'Reader'                                                                   # this too.
  has_many :posts, :order => 'posts.created_at', :include => :reader, :dependent => :destroy

  has_many :monitorships, :dependent => :destroy
  has_many :monitors, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :source => :user, :order => 'users.login'

  validates_presence_of :forum, :reader, :name

  before_validation :set_reader
  before_create :set_default_replied_at_and_sticky
  before_update :check_for_changing_forums
  before_validation_on_create :post_valid?
  after_create :save_post
  before_update :update_post
  
  attr_accessor :body

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

  def paged?() posts_count > 25 end
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i
  end
  
  def page_for(post)
    return nil unless post.topic == self
    return 1 unless paged?
    (posts.index(post)/25).ceil.to_i
  end

  def editable_by?(user)
    reader && (reader.id == reader_id)
  end
  
  def has_posts?
    self.posts_count > 1
  end
  
  def refresh_reply_data(post=nil)
    if !post && self.posts.empty?     # ie. the post has just been deleted and there are no others
      self.destroy
    elsif self.posts.count > 1
      post ||= self.posts.last
      self.last_post = post
      self.replied_by = post.reader
      self.replied_at = post.created_at
      self.save!
    end
  end
  
  def dom_id
    "topic_#{self.id}"
  end
  
  protected

    def set_reader
      self.reader ||= Reader.current_reader
    end
  
    def set_default_replied_at_and_sticky
      self.replied_at ||= Time.now.utc
      self.sticky ||= 0
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
      post = Post.new(:body => self.body, :topic => self)
      unless post.valid?
        self.errors.add(:body, post.errors.on(:body))
        self.errors.add(:reader, post.errors.on(:reader))
        raise ActiveRecord::RecordInvalid.new(self)
      end
      true
    end

    def save_post
      self.first_post = self.posts.create!(:body => self.body, :created_at => self.created_at)
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
