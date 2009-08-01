xml.channel do
  xml.atom :link, nil, {
    :href => posts_list_url(:format => 'rss'),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{@title}"
  xml.description "Latest posts in any topic or forum"
  xml.link posts_list_url
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "post", :collection => @posts, :locals => {:xm => xml}
end
