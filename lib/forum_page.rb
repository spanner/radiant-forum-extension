module ForumPage

  def self.included(base)
    base.class_eval {
      has_one :topic
      include InstanceMethods
    }
  end

  module InstanceMethods     
  
    def find_or_create_topic
      if (self.topic)
        logger.warn "got topic"
        self.topic
      else 
        logger.warn "creating topic"
        topic = self.build_topic(:title => self.title)
        topic.forum = Forum.find_or_create_comments_forum
        topic.save!
        topic
      end
    end
  
    def has_posts?
      self.topic.posts_count > 1
    end
  
    # def cache?
    #   false unless self.topic.nil?
    # end
  
  end
end
