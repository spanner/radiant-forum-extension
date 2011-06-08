@searching = !@term.blank? || @reader || @forum || @topic

xml.channel do
  xml.atom :link, nil, {
    :href => formatted_posts_url(:rss),
    :rel => 'self', :type => 'application/rss+xml'
  }

  if @searching
    summary = [t('forum_extension.topics_and_posts')]
    summary << t('forum_extension.matching') + " '#{@term}'" unless @term.blank?
    summary << t('forum_extension.posted_by') + " #{@reader.name}" if @reader
    summary << t('forum_extension.in_forum') + " #{@forum.name}" if @forum
    xml.title Radiant::Config['site.name'] + ': ' + summary.join(' ')
    xml.description summary.join(' ')
  else
    xml.title Radiant::Config['site.name'] + ': ' + t('forum_extension.latest_posts')
    xml.description t('forum_extension.latest_posts_description')
  end
  
  url_parts = {}
  url_parts[:q] = @term unless @term.blank?
  url_parts[:reader_id] = @reader.id if @reader
  url_parts[:forum_id] = @forum.id if @forum
  url_parts[:reader_id] = @topic.id if @topic
  xml.link posts_url(url_parts)

  xml.language I18n.locale.to_s
  xml.ttl "60"

  render :partial => "posts/post", :collection => @posts, :locals => {:xm => xml}
end
