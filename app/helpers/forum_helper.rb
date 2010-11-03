require 'sanitize'
module ForumHelper

  def home_page_link(options={})
    home_page = (defined? Site && Site.current) ? Site.current.home_page : Page.find_by_parent_id(nil)
    link_to home_page.title, home_page.url, options
  end
  
  def feed_tag(text, url, options={})
    link_to text, url, options.merge(:class => 'floating feedlink')
  end

  def feed_link(url)
    link_to image_tag('/images/furniture/feed_14.png', :class => 'feedicon', :alt => t('rss_feed'), :size => '14x20'), url
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
    link_to t('edit'), edit_topic_post_url(post.topic, post), :class => 'edit_post', :id => "edit_post_#{post.id}", :title => t("edit_post")
  end

  def remove_link(post)
    link_to t('delete'), topic_post_url(post.topic, post), :method => 'delete', :class => 'delete_post', :id => "delete_post_#{post.id}", :title => t("remove_post"), :confirm => t('really_remove_post')
  end
  
  def friendly_date(datetime)
    if datetime
      date = datetime.to_date
      if (date.to_datetime == Date.today)
        format = t('time_today')
      elsif (date.to_datetime == Date.yesterday)
        format = t('time_yesterday')
      elsif (date.to_datetime > 6.days.ago)
        format = t('date_recently')
      elsif (date.year == Date.today.year)
        format = t('date_this_year')
      else
        format = t('standard_date')
      end
      datetime.strftime(format)
    else 
      t("unknown_date")
    end
  end
  
  def pagination_and_summary_for(list, name='')
    %{<div class="pagination">
        #{will_paginate list, :container => false}
        <span class="pagination_summary">
          #{pagination_summary(list, name)}
        </span>
      </div>
    }
  end
    
  def pagination_summary(list, name='')
    total = list.total_entries
    if list.empty?
      %{#{t('no')} #{name.pluralize}}
    else      
      name ||= t(list.first.class.to_s.underscore.gsub('_', ' '))
      if total == 1
        %{#{t('showing')} #{t('one')} #{name}}
      elsif list.current_page == 1 && total < list.per_page
        %{#{t('all')} #{total} #{name.pluralize}}
      else
        start = list.offset + 1
        finish = ((list.offset + list.per_page) < list.total_entries) ? list.offset + list.per_page : list.total_entries
        %{#{start} #{t('to')} #{finish} #{t('of')} #{total} #{name.pluralize}}
      end
    end
  end

end  
