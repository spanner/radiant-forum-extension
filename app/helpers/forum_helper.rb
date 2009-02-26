module ForumHelper

  def self.included(base)
    base.module_eval {
      
      def truncate_words(text, length=64, omission="...")
        words = text.split
        omission = '' unless words.size > length
        words[0..(length-1)].join(" ") + omission
      end

      def gravatar_for(user, gravatar_options={}, img_options ={})
        image_tag user.gravatar_url(gravatar_options), img_options
      end
      
      def feed_tag(text, url, options={})
        link_to text, url, options.merge(:class => 'floating feedlink')
      end

      def feed_link(url)
        link_to image_tag('/images/forum/feed_14.png', :class => 'feedicon', :alt => 'rss feed'), url
      end

      # odd. i get that old erbout error if i use form_tag here:

      def watch_tag(topic, label='watching', formclass=nil)
        if current_user
          monitoring = current_user.monitoring?(topic)
        	%{
        	  <form action="#{monitorship_path(topic.forum, topic)}" method="post" class="#{formclass}"><div>
        	  <input id="monitor_checkbox_#{topic.id}" name="monitor_checkbox" class="monitor_checkbox" type="checkbox"#{ ' checked="checked"' if monitoring } />
        	  <label class="monitor_label" for="monitor_checkbox_#{topic.id}">#{label}</label>
        	  #{hidden_field_tag '_method', monitoring ? 'delete' : ''}
        	  #{submit_tag :set, :class => 'monitor_submit'}
        	  </div></form>
        	}
        end
      end


    }
  end
  
end
