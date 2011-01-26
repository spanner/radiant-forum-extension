module ForumReaderSessionsController

  def self.included(base)
    base.class_eval do
      def default_loggedin_url_with_forum
        Rails.logger.warn ">>> default_loggedin_url is going to be #{topics_url}"
        topics_url
      end
      alias_method_chain :default_loggedin_url, :forum
    end

  end

end
