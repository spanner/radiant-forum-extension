xm.item do
  if post.first?
    xm.title "New topic: #{h(post.topic.name)} (from #{h post.reader.name})"
  elsif (@topic && @topic == post.topic)
    xm.title "Reply from #{h post.reader.name}"
  else
    xm.title "Reply to '#{h(post.topic.name)}' (from #{h post.reader.name})"
  end
  xm.description clean_html(truncate_words(post.body, 64))
  xm.pubDate post.created_at.to_s(:rfc822)
  xm.guid UUIDTools::UUID.timestamp_create(post.created_at).to_s, "isPermaLink" => "false"
  xm.link paginated_post_url(post)
end
