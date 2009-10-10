xml.channel do
  xml.atom :link, nil, {
    :href => posts_url(:format => 'rss'),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{@forum.name}"
  xml.link forum_url(@forum)
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "topics/topic", :collection => @topics, :locals => {:xm => xml}
end