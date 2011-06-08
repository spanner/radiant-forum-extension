xml.channel do
  xml.atom :link, nil, {
    :href => topic_url(@topic, :format => 'rss'),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{@topic.name}"
  xml.description "#{@posts.length} #{t('forum_extension.posts')}, #{t('forum_extension.most_recently')} #{t('forum_extension.from_reader', :name => @posts.last.reader.name)} #{t('forum_extension.on_date', :date => friendly_date(@posts.last.created_at))}"
  xml.link topic_url(@topic)
  xml.language I18n.locale.to_s
  xml.ttl "60"

  render :partial => "posts/post", :object => @topic.posts.first, :locals => {:xm => xml}
  render :partial => "posts/post", :collection => @posts, :locals => {:xm => xml}
end
