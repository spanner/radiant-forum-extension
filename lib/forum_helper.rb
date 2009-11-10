require 'sanitize'
module ForumHelper

  def self.included(base)
    base.module_eval {
      
      def home_page_link(options={})
        home_page = (defined? Site && Site.current) ? Site.current.home_page : Page.find_by_parent_id(nil)
        link_to home_page.title, home_page.url, options
      end
      
      def feed_tag(text, url, options={})
        link_to text, url, options.merge(:class => 'floating feedlink')
      end

      def feed_link(url)
        link_to image_tag('/images/forum/feed_14.png', :class => 'feedicon', :alt => 'rss feed', :size => '14x20'), url
      end

      def clean_textilize(text) # adding smilies to the default reader method
        if text.blank?
          ""
        else
          textilized = RedCloth.new(text, [ :hard_breaks ])
          textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
          Sanitize.clean(textilized.to_html(:textile, :smilies), Sanitize::Config::RELAXED)
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

      def paged_post_url(post)
        if post.first?
          topic_post_url(post.topic, post, :page => post.topic_page, :anchor => post.dom_id)
        else
          topic_post_url(post.topic, post, :page => post.topic_page, :anchor => post.dom_id)
        end
      end

      def edit_link(post)
        link_to 'e', edit_topic_post_url(post.topic, post), :class => 'edit_post', :id => "edit_post_#{post.id}", :title => "edit post"
      end

      def remove_link(post)
        link_to 'x', topic_post_url(post.topic, post), :method => 'delete', :class => 'delete_post', :id => "delete_post_#{post.id}", :title => "remove post", :confirm => "Are you sure you want to delete this message?"
      end
      
      def friendly_date(datetime)
        if datetime
          date = datetime.to_date
          if (date == Date.today)
            format = "today at %l:%M%p"
          elsif (date == Date.yesterday)
            format = "yesterday at %l:%M%p"
          elsif (date.year == Date.today.year)
            format = "on %B %e"
          else
            format = "on %B %e, %Y"
          end
          datetime.strftime(format)
        else 
          "unknown date"
        end
      end
      
      def paginate_and_summarise(list, plural='')
        pagination = will_paginate list, :separator => %{<span class="separator">|</span>}, :container => false
        %{<div class="pagination">
            #{pagination}
            <span class="pagination_summary">
              showing #{pagination_summary(list, plural)}
            </span>
          </div>
        }
      end
        
      def pagination_summary(list, plural='')
        total = list.total_entries
        if total == 1
          if plural.blank?
            "one"
          else
            %{one #{plural.singularize}}
          end
        elsif list.current_page == 1 && total < list.per_page
          %{all #{total} #{plural}}
        else
          start = list.offset + 1
          finish = ((list.offset + list.per_page) < list.total_entries) ? list.offset + list.per_page : list.total_entries
          %{#{start} to #{finish} of #{total} #{plural}}
        end
      end
      
    }
  end
  
end
