xml.channel do
  xml.atom :link, nil, {
    :href => formatted_topics_url(:rss),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : Discussions most recently updated"
  xml.description "The latest new and updated topics"
  xml.link topics_url
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "topic", :collection => @topics, :locals => {:xm => xml}
end
