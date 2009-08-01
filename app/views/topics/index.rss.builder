xml.channel do
  xml.atom :link, nil, {
    :href => topics_feed_url,
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : Forum latest"
  xml.description "The latest new and updated topics"
  xml.link topics_feed_url
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "topic", :collection => @topics, :locals => {:xm => xml}
end
