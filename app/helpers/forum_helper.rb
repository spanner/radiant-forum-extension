module ForumHelper

  def self.included(base)
    base.module_eval {
      
      def feed_tag(text, url, options={})
        link_to text, url, options.merge(:class => 'floating feedlink')
      end

      def feed_link(url)
        link_to image_tag('/images/forum/feed_14.png', :class => 'feedicon', :alt => 'rss feed'), url
      end

      def clean_textilize(text) # adding smilies to the default reader method
        if text.blank?
          ""
        else
          textilized = RedCloth.new(text, [ :hard_breaks ])
          textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
          white_list( textilized.to_html(:textile, :smilies) )
        end
      end
      
      def truncate_and_textilize(text, length)
        clean_textilize( truncate_words(text, length) )
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
