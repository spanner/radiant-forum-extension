xml.channel do
  xml.atom :link, nil, {
    :href => posts_monitored_url(:format => 'rss'),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{@title}"
  xml.description "Your personal feed"
  xml.link posts_monitored_url
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "post", :collection => @posts, :locals => {:xm => xml}
end