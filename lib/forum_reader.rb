module ForumReader

  def self.included(base)
    base.class_eval {
      has_many :topics, :dependent => :nullify
      has_many :posts, :order => 'posts.created_at desc', :dependent => :nullify
      has_many :monitorships, :dependent => :destroy
      has_many :monitored_topics, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :order => 'topics.replied_at desc', :source => :topic

      include InstanceMethods
    }
  end

  module InstanceMethods     
  
    def monitoring?(topic)
       self.monitorship_of(topic).active?
    end
  
    def monitorship_of(topic)
      Monitorship.find_or_create_by_reader_id_and_topic_id(self.id, topic.id)
    end

  end
end