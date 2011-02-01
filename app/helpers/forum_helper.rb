require 'sanitize'
require "sanitize/config/forum"

module ForumHelper
  
  def feed_link(url)
    link_to image_tag('/images/furniture/feed_14.png', :alt => t('rss_feed')), url, :class => "rssfeed"
  end

  def clean_textilize(text) # adding smilies to the default reader method
    if text.blank?
      ""
    else
      textilized = RedCloth.new(text, [ :hard_breaks ])
      textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      Sanitize.clean(textilized.to_html(:textile, :smilies), Sanitize::Config::FORUM)
    end
  end
  
  def paginated_post_url(post)
    param_name = WillPaginate::ViewHelpers.pagination_options[:param_name]
    if post.page
      "post.page.url?#{param_name}=#{post.page_when_paginated}##{post.dom_id}"
    elsif post.first?
      topic_post_url(post.topic, post)
    else
      topic_post_url(post.topic, post, {param_name => post.page_when_paginated, :anchor => post.dom_id})
    end
  end
  
  def link_to_post(post, options={})
    link_to post.holder.title, paginated_post_url(post), options
  end

  def edit_link(post)
    link_to t('edit'), edit_topic_post_url(post.topic, post), :class => 'edit_post', :id => "edit_post_#{post.id}", :title => t("edit_post")
  end

  def remove_link(post)
    link_to t('delete'), topic_post_url(post.topic, post), :method => 'delete', :class => 'delete_post', :id => "delete_post_#{post.id}", :title => t("remove_post"), :confirm => t('really_remove_post')
  end
  
  def friendly_date(datetime)
    I18n.l(datetime, :format => friendly_date_format(datetime)) if datetime
  end
  
  def friendly_date_format(datetime)
    if datetime && date = datetime.to_date
      if (date.to_datetime == Date.today)
        :today
      elsif (date.to_datetime == Date.yesterday)
        :yesterday
      elsif (date.to_datetime > 6.days.ago)
        :recently
      elsif (date.year == Date.today.year)
        :this_year
      else
        :standard
      end
    end
  end
  
end  
