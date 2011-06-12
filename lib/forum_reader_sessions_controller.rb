module ForumReaderSessionsController

  def self.included(base)
    base.class_eval do
      def default_welcome_url_with_forum
        topics_url
      end
      alias_method_chain :default_welcome_url, :forum
    end

  end

end
