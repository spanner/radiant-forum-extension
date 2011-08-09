module ForumReaderSessionsController

  def self.included(base)
    base.class_eval do
      def default_welcome_url_with_forum(reader=nil)
        if Radiant.config['reader.login_to'] == 'forum'
          topics_url
        else
          default_welcome_url_without_forum(reader)
        end
      end
      alias_method_chain :default_welcome_url, :forum
    end

  end

end
