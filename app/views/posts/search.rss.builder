xml.channel do
  xml.atom :link, nil, {
    :href => search_posts_url(:rss),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : forum search"
  xml.description @title
  xml.link search_posts_url(params)
  xml.language "en-us"
  xml.ttl "60"

  render :partial => "post", :collection => @posts, :locals => {:xm => xml}
end
