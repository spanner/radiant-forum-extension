module CommentableModel # for inclusion into ActiveRecord::Base
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def has_comments?
      false
    end

    def has_comments
      return if has_comments?
      has_many :posts, :order => 'posts.created_at ASC', :dependent => :destroy
      belongs_to :replied_by, :class_name => 'Reader' if column_names.include? 'replied_by_id'
      class_eval {
        extend CommentableModel::CommentableClassMethods
        include CommentableModel::CommentableInstanceMethods
      }
      named_scope :last_commented, lambda { |count| {
        :conditions => "replied_at IS NOT NULL",
        :order => "replied_at DESC",
        :limit => count
      }}
    end
  end
  
  module CommentableClassMethods
    def has_comments?
      true
    end
  end
  
  module CommentableInstanceMethods     
    def has_posts?
      posts.any?
    end

    def has_replies?
      posts.count > 1
    end
  
    def replies
      posts.except(posts.first)    # double query but therefore still chainable and paginatable
    end

    def reply_count
      posts.count - 1
    end
  
    def voices
      posts.distinct_readers.map(&:reader)
    end
  
    def voice_count
      posts.distinct_readers.count  #nb. actually counting posts from distinct readers
    end
  
    def other_voices
      voices - [posts.first.reader]
    end
  
    def other_voice_count
      voice_count - 1
    end

    def paged?
      Radiant::Config['forum.paginate_posts?'] && posts.count > posts_per_page
    end

    def posts_per_page
      (Radiant::Config['forum.posts_per_page'] || 25).to_i
    end
  
    def last_page
      (posts.count.to_f/posts_per_page.to_f).ceil.to_i
    end
  
    def page_for(post)
      return nil unless post.holder == self
      return 1 unless paged?
      position = posts.index(post) || posts.count + 1             # new post not always present in cached posts collection
      (position.to_f/posts_per_page.to_f).ceil.to_i
    end
    
    def notice_destruction_of(post)
      if self.respond_to?(:replied_at) && self.replied_at == post.created_at
        set_last_post(self.posts.except(post).last)
      end
    end
    
    def notice_creation_of(post)
      set_last_post(post)
    end
    
    def set_last_post(post=nil)
      if post
        self.replied_by = post.reader if self.respond_to? :replied_by
        self.replied_at = post.created_at if self.respond_to? :replied_at
        self.save if self.changed?
      end
    end

  end
end