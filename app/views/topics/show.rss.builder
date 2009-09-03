xml.channel do
  xml.atom :link, nil, {
    :href => forum_topic_url(@topic.forum, @topic, :format => 'rss'),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{@topic.name}"
  xml.description "#{@posts.length} posts, most recently from #{@posts.last.reader.name} on #{@posts.last.created_at.to_s(:informal)}"
  xml.link forum_topic_url(@topic.forum, @topic)
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "posts/post", :collection => @posts, :locals => {:xm => xml}
end
