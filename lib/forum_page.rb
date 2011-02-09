module ForumPage

  def self.included(base)
    base.class_eval {
      has_comments
      include InstanceMethods
    }
  end

  module InstanceMethods     
    
    def show_comments?
      commentable?
    end
    
    def still_commentable?
      return false unless Radiant::Config['forum.allow_page_comments?'] && commentable?
      return false if comments_closed?
      return true unless commentable_period && commentable_period > 0
      return Time.now - self.created_at < commentable_period
    end
    
    def locked?
      !still_commentable?
    end

  private
  
    def commentable_period
      Radiant::Config['forum.commentable_period'].to_i.days if Radiant::Config['forum.commentable_period']
    end
    
  end
end
