class Topic < ActiveRecord::Base
  is_site_scoped

  belongs_to :forum, :counter_cache => true
  belongs_to :page
  belongs_to :reader
  belongs_to :replied_by, :class_name => 'Reader'
  belongs_to :last_post, :class_name => 'Post'
  has_many :monitorships, :dependent => :destroy
  has_many :monitors, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :source => :user, :order => 'users.login'
  has_many :posts, :order => 'posts.created_at', :dependent => :destroy

  validates_presence_of :forum, :reader, :name

  before_validation :set_reader
  before_create :set_default_replied_at_and_sticky
  before_save   :check_for_changing_forums

  attr_accessor :body # for ease on forms: body is actually first_post.body

  def check_for_changing_forums
    return if new_record?
    old = Topic.find(id)
    if old.forum_id != forum_id
      set_posts_forum_id
      Forum.update_all ["posts_count = posts_count - ?", posts_count], ["id = ?", old.forum_id]
      Forum.update_all ["posts_count = posts_count + ?", posts_count], ["id = ?", forum_id]
    end
  end

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
    post ||= self.posts[-1]
    self.last_post = post
    self.replied_by = post.reader
    self.replied_at = post.created_at
    self.save!
  end
  
  protected

    def set_reader
      self.reader ||= Reader.current_reader
    end
  
    def set_default_replied_at_and_sticky
      self.replied_at ||= Time.now.utc
      self.sticky ||= 0
    end

    def set_posts_forum_id
      Post.update_all ['forum_id = ?', forum_id], ['topic_id = ?', id]
    end
end
