module ForumPage

  def self.included(base)
    base.class_eval {
      has_comments
      include InstanceMethods
    }
  end

  module InstanceMethods     

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
