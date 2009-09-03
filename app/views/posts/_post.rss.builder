xm.item do
  if post.first?
    xm.title "New topic: #{h(post.topic.name)} (from #{h post.reader.name})"
  elsif (@topic && @topic == post.topic)
    xm.title "Reply from #{h post.reader.name}"
  else
    xm.title "Reply to '#{h(post.topic.name)}' (from #{h post.reader.name})"
  end
  xm.description clean_textilize(truncate_words(post.body, 64))
  xm.pubDate post.created_at.to_s(:rfc822)
  xm.guid [ActionController::Base.session_options[:session_key], post.forum_id.to_s, post.topic_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.link paged_post_url(post)
end
