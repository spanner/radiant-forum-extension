xm.item do
  prefix = post == post.topic.posts.first ? "new topic:" : "reply to"
  xm.title "#{prefix} #{h post.topic.name}"
  xm.description clean_textilize("*from #{h post.reader.name}:* " + truncate_words(post.body, 64))
  xm.pubDate post.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, post.forum_id.to_s, post.topic_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{post.reader.name}"
  xm.link topic_url(post.forum_id, post.topic_id)
end
