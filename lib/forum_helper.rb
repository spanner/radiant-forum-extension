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

      def edit_link(post)
        link_to 'edit', edit_post_url(post.forum, post.topic, post), :class => 'edit_post', :id => "edit_post_#{post.id}", :title => "edit post"
      end

      def remove_link(post)
        link_to 'remove', post_url(post.forum, post.topic, post), :method => 'delete', :class => 'remove_post', :title => "remove post", :confirm => "Are you sure you want to delete this message?"
      end

    }
  end
  
end
