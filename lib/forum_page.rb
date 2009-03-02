module ForumPage

  def self.included(base)
    base.class_eval {
      has_one :topic
      include InstanceMethods
    }
  end

  module InstanceMethods     
  
    def find_or_build_topic
      if (self.topic)
        self.topic
      else 
        topic = self.build_topic(:name => self.title)
        topic.forum = Forum.find_or_create_comments_forum
        topic
      end
    end
  
    def posts
      self.topic ? self.topic.posts : []
    end
  
    def has_posts?
      self.topic && self.topic.posts_count > 1
    end
  
    # def cache?
    #   false unless self.topic.nil?
    # end
  
  end
end
