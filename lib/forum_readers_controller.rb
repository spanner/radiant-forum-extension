module ForumReadersController
  def self.included(base)
    base.class_eval do
      helper :forum
      add_show_partial 'readers/forum_messages'
      add_index_partial 'readers/messages_summary'
    end
  end
end
