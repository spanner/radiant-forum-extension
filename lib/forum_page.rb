module ForumPage

  def self.included(base)
    base.class_eval {
      has_one :topic
      include InstanceMethods
    }
  end

  module InstanceMethods     

    def find_or_build_topic
      if self.topic
        self.topic
      elsif self.still_commentable?
        self.build_topic(:name => title, :forum => Forum.find_or_create_comments_forum, :reader => Reader.find_or_create_for_user(created_by))         # posts_controller will do the right thing with a new topic
      end
    end

    def posts
      self.topic ? self.topic.posts : []
    end

    def has_posts?
      self.topic && self.topic.has_posts?
    end

    # def cache?
    #   !has_posts?
    # end

    def still_commentable?
      commentable? && !comments_closed? && (!commentable_period || Time.now - self.created_at < commentable_period)
    end
    
    def commentable_period
      Radiant::Config['forum.commentable_period'].to_i.days if Radiant::Config['forum.commentable_period']
    end
    
    def locked?
      !still_commentable?
    end
  
  end
end
