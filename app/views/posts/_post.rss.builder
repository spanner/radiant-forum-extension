xm.item do
  if post == post.topic.posts.first
    xm.title "#{h(post.topic.name)} (topic started by #{h post.topic.reader.name})"
  elsif (@topic && @topic == post.topic)
    xm.title "reply from #{h post.reader.name}"
  else
    xm.title "reply to #{h(post.topic.name)} from #{h post.reader.name}"
  end
  xm.description clean_textilize(truncate_words(post.body, 64))
  xm.pubDate post.created_at.to_s(:rfc822)
  xm.guid [ActionController::Base.session_options[:session_key], post.forum_id.to_s, post.topic_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.link topic_url(post.forum_id, post.topic_id, :anchor => "comment_#{post.id}")
end
