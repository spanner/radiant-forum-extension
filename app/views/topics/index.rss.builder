xml.channel do
  xml.atom :link, nil, {
    :href => formatted_topics_url(:rss),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{t('forum_extension.latest_topics')}"
  xml.description t("forum_extension.latest_topics_description")
  xml.link topics_url
  xml.language I18n.locale.to_s
  xml.ttl "60"

  render :partial => "topic", :collection => @topics, :locals => {:xm => xml}
end
