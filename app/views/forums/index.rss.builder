xml.channel do
  xml.atom :link, nil, {
    :href => forums_url(:format => 'rss'),
    :rel => 'self', :type => 'application/rss+xml'
  }

  xml.title "#{@site_title} : #{t('forum_extension.forums')}"
  xml.description t('forum_extension.forums')
  xml.link forums_url
  xml.language I18n.locale.to_s
  xml.ttl "60"

  render :partial => "forums/forum", :collection => @forums, :locals => {:xm => xml}
end
